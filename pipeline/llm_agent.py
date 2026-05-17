import os
import json
from openai import OpenAI
from loguru import logger

# 🟢 1. 物理保留并对齐你的阿里云 Dashscope 客户端配置
client = OpenAI(
    api_key="sk-d8c94623ddcb4288b2cb617793e30020",
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
)


def _get_or_create_agent_trace(project_id, agent_name, db_ref):
    if not db_ref or project_id not in db_ref:
        return None
    project = db_ref[project_id]
    if "trace_nodes" not in project or not isinstance(project["trace_nodes"], list):
        project["trace_nodes"] = []

    for agent in project["trace_nodes"]:
        if agent.get("agent_name") == agent_name:
            if "steps" not in agent or not isinstance(agent["steps"], list):
                agent["steps"] = []
            return agent

    agent_node = {
        "agent_name": agent_name,
        "status": "running",
        "title": agent_name,
        "compiler_error": "None",
        "steps": []
    }
    project["trace_nodes"].append(agent_node)
    return agent_node


def _append_agent_step(agent_node, title, status="running", compiler_error="None", output_code=""):
    if agent_node is None:
        return None
    step = {
        "status": status,
        "title": title,
        "compiler_error": compiler_error,
        "output_code": output_code
    }
    agent_node.setdefault("steps", []).append(step)
    agent_node["status"] = status
    return step


def translate_to_structured_logic(project_id, en_text, section_id, section_title, agent_model, db_ref=None, save_callback=None):
    """
    将英文 LaTeX 片段转化为包含翻译、逻辑拆解和 Lean 骨架的结构化 JSON
    """
    # =======================================================================
    # 🟢 Trace 数据总线切面：在不改动核心算法前，向前台压入 Formalization Agent 正在运行的状态
    # =======================================================================
    if db_ref and project_id in db_ref:
        agent_node = _get_or_create_agent_trace(project_id, "Formalization Agent", db_ref)
        _append_agent_step(
            agent_node,
            title=f"正在翻译 Section {section_id}: {section_title}",
            status="running",
            compiler_error="编译器未启动",
            output_code="大模型正全力转换论文原文..."
        )
        if save_callback: save_callback()

    # 原汁原味的系统级指令 (System Prompt)，未动任何一字
    system_prompt = """你是一个严谨的数学形式化（Lean 4）与高阶 LaTeX 排版专家。
    现在你需要处理用户提供的一段英文学术论文片段，将其转化为结构化的中文数学全闭合成果资产。
🎯 核心任务与排版契约（死命令）】：
1. 【LaTeX 翻译质量】：
将输入翻译为专业、流畅的中文数学语言。
保持数学公式（$..$ 或 \\[..\\]）格式的正确性。
保证生成的格式和原pdf的 章节目录(章节标题使用 对应的latex语言包裹\section 和\subsection) 保持一致。
注意，"section_id": "0"中也许包括标题和摘要，在 LaTeX 中并不使用 \section 包裹。
2. 【层级对齐约束】：当前片段在论文原始拓扑中的坐标为：Section ID为 输入json中的section_id，章节标题为 输入json中的section_title。你必须在输出的 JSON 中原样回写这两个字段，绝对不允许丢失或自行修改！
3. 【学术标签强制加粗】：为了保证最终编译的 PDF 与原论文一致，你必须检查正文中的所有学术标签，并确保新开一行，不能与之前的内容在同一行！！！
   - 凡是出现 "Theorem x.x"、"Lemma x.x"、"Definition x.x"、"Proof"、"Remark x.x" 及其对应的中文翻译（如“定理 x.x”、“引理 x.x”、“定义 x.x”、“证明”、“注记 x.x”），必须【百分之百】使用 LaTeX 的加粗控制符包裹

【⚠️ 物理输出规格】：
必须输出严格的 JSON 格式，不得包含 Markdown 围栏（如 ```json）。
JSON 结构必须【严格对齐】以下 Schema：
{{
  "section_id": 输入json中的section_id字段对应的数字,
  "section_title": 输入json中的section_title字段对应的标题,
  "entity_type": "theorem/definition/proof/remark/section/subsection",
  "zh_latex": ""中文 LaTeX 内容",
  "substeps": [
    {{ 
      "id": "step1", 
      "logic": "子步骤的中文微观逻辑描述，若文本含有 Theorem/Proof 等标签，同样必须加粗", 
      "key_point": "对应原代码的关键点", 
      "lean_stub": "Lean 4 代码桩 skeleton (例如: theorem my_lemma : ... := by sorry)" 
    }}
  ]
}}"""

    try:
        # 2. 发起请求（原样保留）
        response = client.chat.completions.create(
            model=agent_model,
            messages=[{
                "role": "system",
                "content": system_prompt
            }, {
                "role": "user",
                "content": f"请处理以下 LaTeX 片段：\n\n{en_text}"
            }],
            temperature=0.1,
            max_tokens=3072,
            response_format={"type": "json_object"}
        )

        raw_content = response.choices[0].message.content.strip()

        # 3. 强力清洗（原样保留）
        clean_content = raw_content.replace("```json", "").replace("```", "").strip()
        
        # 4. 解析并验证 JSON
        try:
            logger.info(">>> 正在解析模型输出的 JSON 结构...")
            parsed_json = json.loads(clean_content)

            # =======================================================================
            # 🟢 Trace 数据总线切面：解析成功后，实时把大模型吐出的 Lean 桩渲染到前端 Trace 面板
            # =======================================================================
            if db_ref and project_id in db_ref:
                agent_node = _get_or_create_agent_trace(project_id, "Formalization Agent", db_ref)
                if agent_node and agent_node.get("steps"):
                    step = agent_node["steps"][-1]
                    step.update({
                        "status": "success",
                        "compiler_error": "None",
                        "output_code": parsed_json.get("zh_latex", "JSON 解析成功，但未提取到 LaTeX 内容")
                    })
                    agent_node["status"] = "success"
                    if save_callback: save_callback()

            return parsed_json
        except Exception:
            logger.warning("❌ 物理括号补齐失败，尝试由 Structured Output Repair Agent 进行 JSON 修复处理。")
            repaired_json = attempt_structured_json_repair(
                project_id,
                raw_content,
                agent_model,
                db_ref=db_ref,
                save_callback=save_callback
            )
            if repaired_json is not None:
                return repaired_json

            logger.critical("❌ Agent 修复失败。放弃本次脏数据写入，下一次执行将重新对本段发起续传。")
            if db_ref and project_id in db_ref:
                repair_node = _get_or_create_agent_trace(project_id, "Structured Output Repair Agent", db_ref)
                if repair_node and repair_node.get("steps"):
                    step = repair_node["steps"][-1]
                    step.update({
                        "status": "fail",
                        "compiler_error": "JSON 格式解析崩溃，大模型未输出合规闭合数据"
                    })
                    repair_node["status"] = "fail"

                formalization_node = _get_or_create_agent_trace(project_id, "Formalization Agent", db_ref)
                if formalization_node and formalization_node.get("steps"):
                    step = formalization_node["steps"][-1]
                    step.update({
                        "status": "fail",
                        "compiler_error": "JSON 解析失败，且结构化输出修复尝试失败"
                    })
                    formalization_node["status"] = "fail"

                if save_callback: save_callback()
            return None

    except Exception as e:
        logger.error(f"API 关键调用失败: {e}")
        if db_ref and project_id in db_ref:
            agent_node = _get_or_create_agent_trace(project_id, "Formalization Agent", db_ref)
            if agent_node and agent_node.get("steps"):
                step = agent_node["steps"][-1]
                step.update({
                    "status": "fail",
                    "compiler_error": f"API 异常中断: {str(e)}",
                    "output_code": ""
                })
                agent_node["status"] = "fail"
                if save_callback: save_callback()
        return None


def attempt_structured_json_repair(project_id, raw_content, agent_model, db_ref=None, save_callback=None):
    """当模型返回非标准 JSON 时，由 agent 重新生成合法 JSON。"""
    repair_prompt = '''请将下面的文本修复为严格合法的 JSON 并保持原始字段结构。只返回 JSON 本体，不要包含任何解释、说明或 markdown 围栏。'''
    try:
        if db_ref and project_id in db_ref:
            agent_node = _get_or_create_agent_trace(project_id, "Structured Output Repair Agent", db_ref)
            _append_agent_step(
                agent_node,
                title="正在修复非标准 JSON 输出...",
                status="running",
                compiler_error="None",
                output_code="Agent 正在尝试自动修复未闭合的 JSON 结构..."
            )
            if save_callback: save_callback()

        response = client.chat.completions.create(
            model=agent_model,
            messages=[
                {"role": "system", "content": repair_prompt},
                {"role": "user", "content": f"原始输出内容：\n{raw_content}"}
            ],
            temperature=0.0,
            max_tokens=1024,
            response_format={"type": "json_object"}
        )
        fixed_raw = response.choices[0].message.content.strip()
        fixed_clean = fixed_raw.replace("```json", "").replace("```", "").strip()
        repaired_json = json.loads(fixed_clean)

        if db_ref and project_id in db_ref:
            agent_node = _get_or_create_agent_trace(project_id, "Structured Output Repair Agent", db_ref)
            if agent_node and agent_node.get("steps"):
                step = agent_node["steps"][-1]
                step.update({
                    "status": "success",
                    "compiler_error": "None",
                    "output_code": "Agent 已修复 JSON 输出，并成功生成合法结构化结果。"
                })
                agent_node["status"] = "success"
                if save_callback: save_callback()

        return repaired_json
    except Exception as repair_error:
        logger.error(f"JSON 修复尝试失败: {repair_error}")
        if db_ref and project_id in db_ref:
            repair_node = _get_or_create_agent_trace(project_id, "Structured Output Repair Agent", db_ref)
            if repair_node and repair_node.get("steps"):
                step = repair_node["steps"][-1]
                step.update({
                    "status": "fail",
                    "compiler_error": f"JSON 修复尝试失败: {repair_error}",
                    "output_code": raw_content
                })
                repair_node["status"] = "fail"

            formalization_node = _get_or_create_agent_trace(project_id, "Formalization Agent", db_ref)
            if formalization_node and formalization_node.get("steps"):
                step = formalization_node["steps"][-1]
                step.update({
                    "status": "fail",
                    "compiler_error": f"JSON 修复尝试失败: {repair_error}",
                    "output_code": raw_content
                })
                formalization_node["status"] = "fail"

            if save_callback: save_callback()
        return None


def fix_latex_with_trace(project_id, old_code, error_trace, agent_model, db_ref=None, save_callback=None):
    """
    # 自愈逻辑：根据 XeLaTeX 的报错信息，让 AI 尝试修复 LaTeX 源码
    """
    # =======================================================================
    # 🟢 Trace 数据总线切面：在进入大模型自愈前，将当前轮次的破坏代码与编译器报错同步登记
    # =======================================================================
    if db_ref and project_id in db_ref:
        agent_node = _get_or_create_agent_trace(project_id, "Auto-Healing Agent", db_ref)
        _append_agent_step(
            agent_node,
            title="正在唤醒自愈大模型纠错中...",
            status="running",
            compiler_error=error_trace if error_trace else "正在分析日志...",
            output_code=old_code
        )
        if save_callback: save_callback()

    system_prompt = """你是一个 LaTeX 诊断专家。用户会给你一段 LaTeX 源码以及编译器的报错 Trace。
任务要求：
1. 分析报错原因（如未闭合的环境、缺失的宏包、特殊的非法字符等）。
2. 修复源码，确保其能够通过 XeLaTeX 编译。
3. 严格只返回修复后的完整 LaTeX 代码，不要包含任何解释、Markdown 围栏或说明文字。"""

    user_content = f"""
【报错信息 (Trace)】:
{error_trace}

【原始代码】:
{old_code}

请修复以上代码，并返回修复后的全文：
"""

    try:
        response = client.chat.completions.create(
            model=agent_model,
            messages=[{
                "role": "system",
                "content": system_prompt
            }, {
                "role": "user",
                "content": user_content
            }],
            temperature=0.1
        )

        fixed_content = response.choices[0].message.content.strip()

        # 清洗可能存在的 Markdown 标签（原样保留）
        fixed_content = fixed_content.replace("```latex", "").replace("```", "").strip()

        # =======================================================================
        # 🟢 Trace 数据总线切面：自愈成功，实时向前端 Trace 树回显修复完成后的完美全新代码
        # =======================================================================
        if db_ref and project_id in db_ref:
            agent_node = _get_or_create_agent_trace(project_id, "Auto-Healing Agent", db_ref)
            if agent_node and agent_node.get("steps"):
                step = agent_node["steps"][-1]
                step.update({
                    "status": "success",
                    "title": "🎉 自愈模型修复策略已生成",
                    "compiler_error": "None",
                    "output_code": fixed_content
                })
                agent_node["status"] = "success"
                if save_callback: save_callback()

        return fixed_content
    except Exception as e:
        logger.error(f"自愈修复调用失败: {e}")
        if db_ref and project_id in db_ref and db_ref[project_id]["trace_nodes"]:
            db_ref[project_id]["trace_nodes"][-1].update({
                "status": "fail",
                "compiler_error": f"自愈大模型调用崩溃: {str(e)}"
            })
            if save_callback: save_callback()
        return old_code


# =====================================================================
# 🟢 2. 决策状态机：完美支持物理控制命令 + 工作区文件感知自由对话
# =====================================================================
def execute_agent_logic(project_id: str, command: str, db_ref: dict = None, save_callback=None) -> str:
    """
    控制台命令执行路由器：具备本地项目文件感知能力的真 RAG 智能体对话中枢
    """
    logger.info(f"【Agent 接收指令】项目: {project_id} | 指令/提问: '{command}'")

    # 对齐项目物理路径
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    project_path = os.path.join(base_dir, "artifacts", "projects", project_id)
    main_tex_file = os.path.join(project_path, "main.tex")

    # 鲁棒性保护（原样保留）
    if db_ref is None:
        try:
            from backend.main import projects_db
            db_ref = projects_db
        except Exception:
            db_ref = {}
    try:
        from backend.main import projects_db
        agent_model = projects_db[project_id].get("agent_type", "qwen-max") if project_id in projects_db else "qwen-max"
    except Exception:
        agent_model = "qwen-max"

    # -----------------------------------------------------------------
    # 【分支 A：高优先级物理命令拦截】（原样保留）
    # -----------------------------------------------------------------
    if "重新编译" in command or "compile" in command.lower():
        if os.path.exists(os.path.join(project_path, "main.aux")): os.remove(os.path.join(project_path, "main.aux"))
        if os.path.exists(os.path.join(project_path, "main.log")): os.remove(os.path.join(project_path, "main.log"))
        if os.path.exists(os.path.join(project_path, "main.pdf")): os.remove(os.path.join(project_path, "main.pdf"))
        if os.path.exists(os.path.join(project_path, "intermediate", "zh_fragments.jsonl")):
            os.remove(os.path.join(project_path, "intermediate", "zh_fragments.jsonl"))
        if os.path.exists(os.path.join(project_path, "intermediate", "formalization.json")):
            os.remove(os.path.join(project_path, "intermediate", "formalization.json"))
        logger.info(f"--- Agent 响应控制台指令：开始对项目 {project_id} 进行物理重新编译 ---")
        from pipeline.core import run_pipeline

        run_pipeline(project_id, project_path, db_ref, save_callback)
        return {"status": "success", "message": "编译并刷新图谱成功"}
        
    elif "继续编译" in command or "compile" in command.lower():
        if not os.path.exists(main_tex_file) and not os.path.exists(project_path):
            return f"❌【Agent 编译中止】未在工作区找到主编译环境：{project_path}"

        logger.info(f"--- Agent 响应控制台指令：开始对项目 {project_id} 进行物理继续编译 ---")
        from pipeline.core import run_pipeline

        run_pipeline(project_id, project_path, db_ref, save_callback)
        return {"status": "success", "message": "编译并刷新图谱成功"}
        
    elif "当前状态" in command or "状态" in command:
        return f"【PaperLean 状态汇报】激活工作区：{project_path}。环境连接就绪，你可以向我询问任何学术或 Lean 4 形式化问题。"

    elif "日志" in command or "trace" in command:
        log_file = os.path.join(project_path, "main.log")
        if os.path.exists(log_file):
            return f"【系统日志位置】本地物理追踪日志位于: {log_file}"
        return "【系统日志检索】最近一次本地编译器返回状态正常，未捕获到崩溃日志。"

    # -----------------------------------------------------------------
    # 【分支 B：自由对话兜底 —— 真实投递给通义千问回答】（原样保留）
    # -----------------------------------------------------------------
    logger.info(">>> 拦截到非控制指令，启动项目文件上下文感知矩阵...")

    fragments_context = ""
    frag_path = os.path.join(project_path, "intermediate", "zh_fragments.jsonl")
    if os.path.exists(frag_path):
        try:
            with open(frag_path, "r", encoding="utf-8") as f:
                lines = f.readlines()[-5:]
                fragments_context = "\n".join([
                    json.loads(line.strip()).get("content", "")
                    for line in lines if line.strip()
                ])
        except Exception as e:
            fragments_context = f"(片段读取挂起: {e})"

    lean_context = ""
    lean_file = os.path.join(project_path, "skeleton.lean")
    if os.path.exists(lean_file):
        try:
            with open(lean_file, "r", encoding="utf-8") as f:
                lean_context = f.read()[-1500:]
        except Exception:
            pass

    system_prompt = f"""你是一个部署在 PaperLean 系统内部的论文形式化（Lean 4）协同大模型专家。
    当前用户正在你的控制台中管理项目工作区，项目 ID 为: {project_id}。

    【当前项目工作区的本地磁盘文件切片上下文】:
    1. 提取出的中英文数学公式/证明片段:
    {fragments_context if fragments_context else "暂无已生成的结构化片段。"}

    2. 当前工作区的 Lean 4 形式化代码桩上下文:
    {lean_context if lean_context else "-- 暂无已生成的 Lean 源码。"}
    任务要求：
    请基于上述真实的文件上下文切片，精准、严谨地回答用户发来的控制台提问。如果用户提问了关于 LaTeX 语法、Lean 证明步骤（如 sorry 如何填补）或者公式逻辑，请给出详尽且符合形式化规范的推演回答。"""

    try:
        logger.info(f"正在将上下文递交给通义千问底座 ({agent_model})...")
        response = client.chat.completions.create(
            model=agent_model,
            messages=[{
                "role": "system",
                "content": system_prompt
            }, {
                "role": "user",
                "content": command
            }],
            temperature=0.6,
        )
        return response.choices[0].message.content.strip()

    except Exception as llm_err:
        logger.error(f"控制台真实大模型调用失败: {llm_err}")
        return f"❌【Agent 沟通失败】我已成功感知并读取了你的项目文件，但在通过阿里云网关呼叫大模型底座时发生异常: {str(llm_err)}"


def extract_main_theorem_manifest(project_id, all_fragments, agent_model, db_ref=None, save_callback=None):
    """
    分析项目全量逻辑片段，提炼并深度解构整篇论文最具代表性的主定理元 metadata
    """
    logger.info(">>> 启动全局主定理（Main Theorem）高阶语义提炼算子...")

    # =======================================================================
    # 🟢 Trace 数据总线切面：在提炼图谱前，压入 Theorem Extractor 节点的运行状态
    # =======================================================================
    if db_ref and project_id in db_ref:
        agent_node = _get_or_create_agent_trace(project_id, "Theorem Extractor", db_ref)
        _append_agent_step(
            agent_node,
            title="正在提炼并全量解构主定理知识图谱",
            status="running",
            compiler_error="None",
            output_code="图谱语义网络正在构建中..."
        )
        if save_callback: save_callback()

    context_clips = []
    for frag in all_fragments:
        context_clips.append(
            f"Fragment ID: {frag['id']} | Type: {frag['entity_type']} | Content: {frag['content'][:300]}"
        )

    global_context = "\n".join(context_clips)

    system_prompt = """你是一个世界顶级的数学家兼 Lean 4 形式化专家。
请审查用户提供的全篇论文逻辑片段摘要，精准找出整篇论文最具代表性、最核心的“主定理（Main Theorem）”。
一旦锁定该主定理，请输出严格的 JSON 格式，解构并填充以下字段（切勿包含 Markdown 围栏标签）：

{
  "node_id": "该定理在片段中对应的真实 ID (例如 p1_s12)",
  "title": "主定理的标志性简短名称",
  "theorem_desc_en": "主定理的完整原始英文 LaTeX 描述",
  "theorem_desc_zh": "主定理的高质量专业中文 LaTeX 翻译描述",
  "proof_strategy": "深度剖析该定理的证明思路（逐步层层拆解，说明各个核心引理、多项式直径替换或低次 Hilbert 函数在其中扮演的角色）",
  "supplementary_notes": "关于该定理的重要补充说明（如：它的应用边界、在指数增长阶上的定性定量的突破、与其他经典理论如 Rajagopal 定理的对比或历史沿革等）",
  "lean_code": "该主定理 in Lean 4 中的顶层完备声明与宏观形式化骨架（使用 := by sorry 闭合证明体）"
}"""

    try:
        response = client.chat.completions.create(
            model=agent_model,
            messages=[{
                "role": "system",
                "content": system_prompt
            }, {
                "role": "user",
                "content": f"【论文全量逻辑片段上下文堆栈】:\n{global_context}\n\n请严格基于上述论文堆栈，提炼并输出最核心的主定理 JSON 架构。"
            }],
            temperature=0.2,
            response_format={"type": "json_object"}
        )

        raw_res = response.choices[0].message.content.strip()
        clean_res = raw_res.replace("```json", "").replace("```", "").strip()
        parsed_manifest = json.loads(clean_res)

        # =======================================================================
        # 🟢 Trace 数据总线切面：图谱构建成功，更新状态并将 Lean 骨架打入 Trace 面板
        # =======================================================================
        if db_ref and project_id in db_ref:
            agent_node = _get_or_create_agent_trace(project_id, "Theorem Extractor", db_ref)
            if agent_node and agent_node.get("steps"):
                step = agent_node["steps"][-1]
                step.update({
                    "status": "success",
                    "title": f"🎉 成功解构核心主定理: {parsed_manifest.get('title', '知识图谱')}",
                    "compiler_error": "None",
                    "output_code": parsed_manifest.get("lean_code", "图谱生成完毕")
                })
                agent_node["status"] = "success"
                if save_callback: save_callback()

        return parsed_manifest
    except Exception as e:
        logger.error(f"提取核心主定理清单失败: {e}")
        if db_ref and project_id in db_ref and db_ref[project_id]["trace_nodes"]:
            db_ref[project_id]["trace_nodes"][-1].update({
                "status": "fail",
                "compiler_error": f"图谱提炼失败: {str(e)}"
            })
            if save_callback: save_callback()
        return None