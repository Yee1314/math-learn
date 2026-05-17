import json
import os
import traceback
from loguru import logger
from pipeline.pdf_parser import parse_pdf_to_pages
# 🟢 完美导入 llm_agent.py 中定义好的专家能力与自愈决策器
from pipeline.llm_agent import translate_to_structured_logic, fix_latex_with_trace
from pipeline.compiler import compile_with_auto_healing


def _record_project_trace_failure(project_id, db_ref, failure_reason, agent_name="Pipeline Failure", save_callback=None):
    if not db_ref or project_id not in db_ref:
        return
    project = db_ref[project_id]
    if "trace_nodes" not in project or not isinstance(project["trace_nodes"], list):
        project["trace_nodes"] = []

    node = None
    for existing in project["trace_nodes"]:
        if existing.get("agent_name") == agent_name:
            node = existing
            break

    if node is None:
        node = {
            "agent_name": agent_name,
            "status": "fail",
            "title": agent_name,
            "compiler_error": failure_reason,
            "steps": [
                {
                    "status": "fail",
                    "title": "失败原因",
                    "compiler_error": failure_reason,
                    "output_code": ""
                }
            ]
        }
        project["trace_nodes"].append(node)
    else:
        node["status"] = "fail"
        node["compiler_error"] = failure_reason
        if "steps" not in node or not isinstance(node["steps"], list):
            node["steps"] = []
        node["steps"].append({
            "status": "fail",
            "title": "失败原因",
            "compiler_error": failure_reason,
            "output_code": ""
        })

    if save_callback:
        save_callback()


def run_pipeline(project_id, project_path, db_ref, save_callback=None):
    handler_id = None
    try:
        logger.info(f">>> 启动项目 {project_id} 的深度逻辑 Pipeline")

        # 路径初始化
        input_dir = os.path.join(project_path, "inputs")
        inter_dir = os.path.join(project_path, "intermediate")
        project_logs_dir = os.path.join(project_path, "logs")
        os.makedirs(inter_dir, exist_ok=True)
        os.makedirs(project_logs_dir, exist_ok=True)
    
        project_log_file = os.path.join(project_logs_dir, "agent.log")
        # 2. 注册项目独占的微观日志管道，使用独立 filter 确保数据纯净无踩踏
        # 🟢 核心修复 1：升级 Filter 算子，允许拦截带有隐形上下文字段（extra）的日志
        handler_id = logger.add(
            project_log_file,
            format="{time:YYYY-MM-DD HH:mm:ss.SSS} | {level:<8} | {name}:{function}:{line} - {message}",
            filter=lambda r: r["extra"].get("project_id") == project_id or project_id in r["message"],
            encoding="utf-8",
            enqueue=True  # 启用队列防死锁
        )
        # =======================================================
        
        with logger.contextualize(project_id=project_id):
            # 往这个项目专属的文件里打入第一行初始化标记
            logger.info(f"[{project_id}] >>> 激活 Formalization Agent 局部微观工作总线，日志已启动 <<<")
            anchors_file = os.path.join(inter_dir, "anchors.json")
            fragments_file = os.path.join(inter_dir, "zh_fragments.jsonl")
            tex_path = os.path.join(project_path, "main.tex")

            # --- 步骤 1：PDF 物理提取 ---
            # ========================================================
            # 🟢 步骤 1：PDF 物理提取（引入 projects_db 状态机 + 磁盘双重对齐校验）
            # ========================================================
            current_step = db_ref[project_id].get("current_step", "idle")
            anchors_exist = os.path.exists(anchors_file) and os.path.getsize(
                anchors_file) > 0

            # 💡 核心策略：如果状态已经跨越了提取阶段（处于翻译、编译或成功状态），且磁盘上有物理产物，则果断跳过
            if current_step in ["translating", "compiling","finding", "success"
                                ] and anchors_exist:
                logger.success(f"ℹ️ PDF 切分完成，安全跳过物理提取步骤。")
            else:
                logger.info("🔄 PDF 切分未完成，启动 PDF 文本与数学锚点物理提取...")

                db_ref[project_id]["current_step"] = "extracting"
                db_ref[project_id]["status_msg"] = "提取 PDF 文本与数学锚点..."
                if save_callback: save_callback()

                files = [
                    f for f in os.listdir(input_dir) if f.lower().endswith('.pdf')
                ]
                if not files: raise Exception("未找到 PDF 文件")

                pdf_path = os.path.join(input_dir, files[0])
                parse_pdf_to_pages(pdf_path, inter_dir)

            # --- 步骤 2：结构化逻辑转化与拆解 ---
            db_ref[project_id]["current_step"] = "translating"
            agent_model = db_ref[project_id].get("agent_type", "qwen-max")
            if save_callback: save_callback()
            anchors_file = os.path.join(inter_dir, "anchors.json")
            fragments_file = os.path.join(inter_dir, "zh_fragments.jsonl")

            with open(anchors_file, "r", encoding="utf-8") as f:
                anchors = json.load(f)
            if not anchors:
                raise Exception("anchors.json 物理实体为空，无法进行后续大模型拆解。")
            all_zh_fragments = []
            existing_ids = set()
            if os.path.exists(fragments_file):
                with open(fragments_file, "r", encoding="utf-8") as f:
                    for line in f:
                        try:
                            data = json.loads(line)
                            # 防御性校验：如果发现历史落盘数据是个“空壳”或者 substeps 缺失核心增强字段，不将其加入去重集，允许重跑覆盖
                            has_enhanced_substeps = True
                            if data.get("substeps"):
                                for s in data["substeps"]:
                                    if "logic" not in s and "title" not in s:
                                        has_enhanced_substeps = False
                            if has_enhanced_substeps and data.get(
                                    "content") or data.get("zh_latex"):
                                all_zh_fragments.append(data)
                                existing_ids.add(data["id"])
                        except:
                            continue

            pending_anchors = [
                a for a in anchors if a["en_anchor_id"] not in existing_ids
            ]
            if len(pending_anchors) == 0 and len(all_zh_fragments) == len(anchors):
                logger.success(f"ℹ️ 翻译完备性校验通过：全量 {len(anchors)} 个段落已就绪，跳过大模型交互。")
            else:

                logger.warning(
                    f"⚠️ 校验未通过：PDF 总锚点 {len(anchors)} 段，已翻译 {len(all_zh_fragments)} 段。正在对剩余 {len(pending_anchors)} 段进行断点续传..."
                )
                with open(fragments_file, "a", encoding="utf-8") as f:
                    for anchor in pending_anchors:
                        db_ref[project_id][
                            "status_msg"] = f"正在翻译第 {len(all_zh_fragments)+1}/{len(anchors)} 段..."
                        if save_callback: save_callback()
                        en_text = anchor.get("snippet", "")
                        anchor_id = anchor.get("en_anchor_id")
                        # 物理抓取当前锚点绝对正确的 章节 ID 和 章节标题
                        curr_section_id = str(anchor.get("section_id", "0"))
                        curr_section_title = anchor.get("section_title", "未分类微观逻辑")
                        # 调用从 llm_agent 引入的结构化 Agent
                        structured_res = translate_to_structured_logic(
                            project_id=project_id,
                            en_text=en_text,
                            section_id=curr_section_id,
                            section_title=curr_section_title,
                            agent_model=agent_model,
                            db_ref=db_ref)

                        if not structured_res:
                            failure_reason = (
                                f"Section {curr_section_id} {curr_section_title} 结构化转化失败，无法获得合法 JSON 输出。"
                            )
                            logger.error(
                                f"[{project_id}] {failure_reason}"
                            )
                            db_ref[project_id]["status"] = "fail"
                            db_ref[project_id]["status_msg"] = (
                                "结构化转化失败，项目已中止。请检查 API 配额或模型调用设置。"
                            )
                            _record_project_trace_failure(
                                project_id,
                                db_ref,
                                failure_reason,
                                agent_name="Formalization Agent",
                                save_callback=save_callback,
                            )
                            return

                        # 🟢 字段双向对齐契约：同时灌入 content 和 zh_latex，彻底打通中英文对照面板所有分支的读取习惯！
                        zh_text = structured_res.get(
                            "zh_latex") or structured_res.get("content", "")
                        fragment_data = {
                            "id":
                            anchor["en_anchor_id"],
                            "page":
                            anchor["page"],
                            "section_id":
                            anchor.get("section_id", ""),
                            "section_title":
                            anchor.get("section_title", ""),
                            "entity_type":
                            structured_res.get("entity_type", "other"),
                            "zh_latex":
                            zh_text+"\n",  # 确保每段落后都有换行，保持 LaTeX 源码的物理可读性
                            "content":
                            zh_text,
                            "source_snippet":
                            en_text,
                            "substeps":
                            structured_res.get("substeps", []),
                        }
                        all_zh_fragments.append(fragment_data)
                        f.write(
                            json.dumps(fragment_data, ensure_ascii=False) +
                            "\n")
                        f.flush()
                        logger.info(f">>> 成功翻译并落盘第 {len(all_zh_fragments)}/{len(anchors)} 段段落  ")

            # --- 步骤 3：生成 Lean 骨架与全文 LaTeX ---
            # 如果状态机显示已成功，且前端需要的图谱资产已经在磁盘上物理固化，则直接跳过后续的生成与自愈编译
            if current_step == "success" and os.path.exists(graph_path) and os.path.getsize(graph_path) > 0:
                logger.success(f"ℹ️ 项目逻辑图谱与 LaTeX 编译已处于成功状态，完美跳过代码生成与自愈编译。")
                return # 优雅落幕，不再向下走重跑流程
            db_ref[project_id]["status_msg"] = "正在生成 LaTeX 源码..."
            db_ref[project_id]["current_step"] = "compilinglatex"
            if save_callback: save_callback()
            all_zh_fragments.sort(key=lambda x: x['page'])
            lean_codes = []
            full_latex_body = ""
            for frag in all_zh_fragments:
                full_latex_body += frag['content'] + "\n"
                for step in frag.get("substeps", []):
                    if step.get("lean_stub"):
                        lean_codes.append(
                            f"-- ID: {frag['id']}_{step['id']}\n{step['lean_stub']}"
                        )

           

            # LaTeX 模板合成
            latex_template = self_generate_template(full_latex_body)
            tex_path = os.path.join(project_path, "main.tex")
            with open(tex_path, "w", encoding="utf-8") as f:
                f.write(latex_template)
            db_ref[project_id]["status_msg"] = "正在生成 Lean 骨架..."
            db_ref[project_id]["current_step"] = "compilinglean"
             # 保存 Lean 文件
            with open(os.path.join(project_path, "skeleton.lean"),
                    "w",
                    encoding="utf-8") as f:
                f.write("\n\n".join(lean_codes))
            # --- 步骤 4：自愈式编译 ---
            db_ref[project_id]["current_step"] = "compiling"
            db_ref[project_id]["status_msg"] = "启动自愈式编译..."
            if save_callback: save_callback()
            success = compile_with_auto_healing(project_id,project_path, tex_path,
                                                agent_model,db_ref=db_ref)

            if success:
            # if True:
                db_ref[project_id]["status_msg"] = "所有逻辑节点已生成并成功修复编译！"
                
                # 将嵌套的 substeps 铺平，导出给前端拓扑图谱
                try:
                    db_ref[project_id]["status_msg"] = "正在查找核心定理"
                    db_ref[project_id]["current_step"] = "finding"
                    formalization_nodes = []
                    seen_node_ids = set()
                    for frag in all_zh_fragments:
                        for step_index, step in enumerate(frag.get("substeps", []), start=1):
                            # 从大模型的 logic 字段中切出前 10 个字作为标题，或者用更好的规则
                            raw_logic = step.get("logic", "数学逻辑推导步骤")
                            short_title = raw_logic[:15] + "..." if len(
                                raw_logic) > 15 else raw_logic
                            raw_step_id = step.get("id") or f"step{step_index}"
                            node_id = f"{frag['id']}_{raw_step_id}"
                            if node_id in seen_node_ids:
                                node_id = f"{node_id}_{step_index}"
                            seen_node_ids.add(node_id)

                            node_data = {
                                "id": node_id,
                                "type":
                                step.get(
                                    "type", "Theorem" if "theorem" in step.get(
                                        "lean_stub", "").lower() else "Lemma"),
                                "source_anchor_id": frag.get("id"),
                                "source_page": frag.get("page"),
                                "source_section_id": frag.get("section_id", ""),
                                "source_section_title": frag.get("section_title", ""),
                                "source_snippet": frag.get("source_snippet", ""),
                                # 🟢 完美对齐：前端需要 title 和 description，我们用大模型吐出的 logic 和 key_point 精准喂饱它！
                                "title":
                                step.get("title",
                                        f"步骤_{raw_step_id} ({short_title})"),
                                "description":
                                step.get("logic", "论文对应数学片段推理描述") +
                                f" [核心键点: {step.get('key_point', '无')}; 来源: {frag.get('id')} 页{frag.get('page')}]",
                                "lean_code":
                                step.get("lean_stub", "-- 无源码")
                            }
                            formalization_nodes.append(node_data)

                    graph_path = os.path.join(project_path, "intermediate",
                                            "formalization.json")
                    with open(graph_path, "w", encoding="utf-8") as gf:
                        json.dump(formalization_nodes,
                                gf,
                                ensure_ascii=False,
                                indent=4)
                    logger.info(f">>> 成功为项目 {project_id} 导出图谱文件: {graph_path}")
                    # ========================================================
                    # 🟢 [新功能集成] 自动化提取、解构并导出核心主定理资产清单
                    # ========================================================
                    from pipeline.llm_agent import extract_main_theorem_manifest

                    manifest_res = extract_main_theorem_manifest(
                        project_id,
                        all_zh_fragments, agent_model,db_ref=db_ref)
                    if manifest_res:
                        manifest_path = os.path.join(project_path, "intermediate",
                                                    "core_theorem_manifest.json")
                        with open(manifest_path, "w", encoding="utf-8") as mf:
                            json.dump(manifest_res,
                                    mf,
                                    ensure_ascii=False,
                                    indent=4)
                        logger.success(
                            f"🏆 【主定理发现成功】核心成果清单已成功落盘固化: {manifest_path}")

                        # 同步刷新到数据库中，让前端动态感知
                        db_ref[project_id]["main_theorem"] = manifest_res
                    # ========================================================
                        db_ref[project_id]["status"] = "success"
                        db_ref[project_id]["current_step"] = "success"
                        db_ref[project_id]["status_msg"] = "项目处理成功。"
                except Exception as graph_err:
                    logger.error(f"导出图谱 JSON 失败: {graph_err}")
            else:
                db_ref[project_id]["status"] = "fail"
                db_ref[project_id]["status_msg"] = "LaTeX 编译失败，自愈尝试已达上限。"

            if save_callback: save_callback()

    except Exception as e:
        failure_reason = f"Pipeline 未捕获异常: {str(e)}"
        logger.error(f"Pipeline 崩溃: {traceback.format_exc()}")
        db_ref[project_id]["status"] = "fail"
        db_ref[project_id]["status_msg"] = "Pipeline 发生异常，项目已终止。请检查日志和 trace_nodes。"
        _record_project_trace_failure(
            project_id,
            db_ref,
            failure_reason,
            agent_name="Pipeline Failure",
            save_callback=save_callback,
        )
        if save_callback: save_callback()

    finally:
        if handler_id is not None:
            try:
                logger.remove(handler_id)
            except Exception:
                pass


def self_generate_template(body):
    return r"""\documentclass[11pt]{article}
\usepackage[UTF8]{ctex}
\usepackage{amsmath,amssymb,amsthm}
\usepackage{etoolbox}

% 1. 自定义定理样式实现标题后强制换行
\newtheoremstyle{break}% 样式名称
  {\topsep}{\topsep}% 环境上下间距
  {\normalfont}% 正文字体
  {}% 缩进量
  {\bfseries}{.}% 头部字体和标点
  {\newline}% 头部后的间距：设置为 \newline 即可实现完美的换行效果
  {}% 头部时间/附加参数规范

% 应用新样式并声明常用的定理类环境
\theoremstyle{break}
\newtheorem{theorem}{定理}[section]
\newtheorem{lemma}[theorem]{引理}
\newtheorem{corollary}[theorem]{推论}
\newtheorem{definition}[theorem]{定义}

% 2. 利用 etoolbox 宏包动态修补 proof 环境，使其标题后自动换行
\patchcmd{\proof}{\item[\hskip\labelsep\itshape#1\@addpunct{.}]}{\item[\hskip\labelsep\itshape#1\@addpunct{.}]\hfill\par}{}{}

\begin{document}
""" + body + r"""\end{document}"""
