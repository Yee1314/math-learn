import os
from pydantic import BaseModel
import uuid
import sys
import shutil
from loguru import logger
from typing import List
from fastapi import FastAPI, BackgroundTasks, UploadFile, File, Form, HTTPException, status,APIRouter
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse,JSONResponse
from pipeline.core import run_pipeline
import json
import contextlib
# 使用 lifespan 替代旧的 on_event("startup")
@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    # --- 启动时执行：自动恢复中断的任务 ---
    if app_config.get("auto_resume_on_startup", False):
        logger.info("自动恢复开启：正在检查未完成的待恢复任务...")
        for project_id, info in projects_db.items():
            if info.get("status") == "running":
                logger.warning(f"发现中断任务 {project_id}，正在尝试自动重启...")
                project_path = os.path.join(PROJECTS_DIR, project_id)

                # 重新启动后台任务
                # 注意：这里我们不需要通过 BackgroundTasks 注入，
                # 直接通过 asyncio 或者在一个线程中运行即可
                import threading
                thread = threading.Thread(
                    target=run_pipeline,
                    args=(project_id, project_path, projects_db, save_db)
                )
                thread.start()
            elif info.get("status") == "fail":
                logger.warning(f"发现失败任务 {project_id}，正在尝试重新编译...")
                project_path = os.path.join(PROJECTS_DIR, project_id)

                import threading
                thread = threading.Thread(
                    target=run_pipeline,
                    args=(project_id, project_path, projects_db, save_db)
                )
                thread.start()

    else:
        logger.info("自动恢复已关闭：启动时不重启上次运行中的项目。")
        # 在这里添加逻辑：将之前运行中的项目状态重置为"interrupted"
        for project_id, info in projects_db.items():
            if info.get("status") == "running":
                logger.info(f"检测到中断的运行中项目 {project_id}，重置为'中断'状态，允许用户删除")
                info["status"] = "interrupted"
                info["status_msg"] = "服务重启时任务中断，需要重新启动"


    yield
    # --- 关闭时执行（可选） ---
    save_db()

app = FastAPI(lifespan=lifespan)
router = APIRouter()
# --- 基础配置 ---
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
STATIC_DIR = os.path.join(BASE_DIR, "static")
PROJECTS_DIR = os.path.join(BASE_DIR, "artifacts", "projects")
# 新增：定义数据库文件路径
DB_FILE = os.path.join(BASE_DIR, "artifacts", "projects_db.json")
CONFIG_FILE = os.path.join(BASE_DIR, "artifacts", "app_config.json")

# 换成下面这三行 👇
LOGS_DIR = os.path.join(BASE_DIR, "logs")  # 文件夹
LOG_FILE = os.path.join(LOGS_DIR, "app.log")  # 文件


# 确保 artifacts 根目录存在
os.makedirs(PROJECTS_DIR, exist_ok=True)
os.makedirs(LOGS_DIR, exist_ok=True)  # 先创建文件夹

# 注册全局物理落地句柄，设置 rotation 防止文件过大，并使用 utf-8 编码保护中文 LaTeX
logger.add(LOG_FILE, rotation="10 MB", encoding="utf-8", enqueue=True)
logger.info(">>> PaperLean 全栈安全日志总线物理挂载成功 <<<")
# 检查是否有这一行！没有的话前端读不到磁盘文件
app.mount("/artifacts", StaticFiles(directory="artifacts"), name="artifacts")
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# --- 持久化逻辑 ---
def load_db():
    """从磁盘加载项目列表"""
    if os.path.exists(DB_FILE):
        try:
            with open(DB_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ 加载数据库失败: {e}")
            return {}
    return {}


def load_config():
    """加载后端启动配置"""
    default = {"auto_resume_on_startup": False}
    if os.path.exists(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            print(f"❌ 加载配置失败: {e}")
            return default
    return default


def save_config():
    """将后端运行配置保存到磁盘"""
    try:
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            json.dump(app_config, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"❌ 保存配置失败: {e}")


def save_db():
    """将内存中的项目列表保存到磁盘"""
    try:
        with open(DB_FILE, "w", encoding="utf-8") as f:
            json.dump(projects_db, f, ensure_ascii=False, indent=2)
    except Exception as e:
        print(f"❌ 保存数据库失败: {e}")

# 初始化：启动时加载数据
projects_db = load_db()
app_config = load_config()

@app.get("/")
async def read_index():
    return FileResponse(os.path.join(STATIC_DIR, "index.html"))

# --- 核心接口：创建项目 (合并了校验与保存) ---
@app.post("/api/projects")
async def create_project(
    name: str = Form(...),
    agent_type: str = Form(...),
    file: UploadFile = File(...)
):
    # 1. 安全校验
    if not name.strip():
        raise HTTPException(status_code=400, detail="项目名称不能为空")

    if not file.filename.lower().endswith(".pdf"):
        raise HTTPException(status_code=400, detail="仅支持 PDF 文件格式")

    # 检查文件内容
    content = await file.read()
    if len(content) == 0:
        raise HTTPException(status_code=400, detail="上传的文件内容不能为空")
    await file.seek(0) # 必须要重置指针，否则后面保存的文件是空的

    # 2. 生成 ID 和 路径
    project_id = str(uuid.uuid4())[:8]
    project_path = os.path.join(PROJECTS_DIR, project_id)

    # 3. 创建物理目录
    for sub in ["inputs", "intermediate", "outputs/zh", "logs"]:
        os.makedirs(os.path.join(project_path, sub), exist_ok=True)

    # 4. 保存文件
    file_path = os.path.join(project_path, "inputs", file.filename)
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 5. 写入内存数据库
    project_info = {
        "id": project_id,
        "name": name.strip(),
        "agent_type": agent_type,
        "filename": file.filename,
        "status": "created",
    }
    projects_db[project_id] = project_info
    save_db()
    print(f"✅ Project Created: {project_info}") # 后端控制台日志
    return project_info

@app.get("/api/projects")
async def list_projects():
    print(f"📊 Current DB state: {list(projects_db.keys())}")
    return list(projects_db.values())

@app.post("/api/projects/{project_id}/run")
async def run_project(project_id: str, background_tasks: BackgroundTasks):
    if project_id in projects_db:
        # 修改状态为运行中
        projects_db[project_id]["status"] = "running"
        save_db()
        project_path = os.path.join(PROJECTS_DIR, project_id)

        # 核心修改：把 save_db 函数本身作为参数传给 run_pipeline
        background_tasks.add_task(run_pipeline, project_id, project_path, projects_db, save_db)

        return {"status": "started", "project_id": project_id}
    raise HTTPException(status_code=404, detail="项目不存在")
@app.get("/api/projects/{project_id}")
async def get_project_detail(project_id: str):
    if project_id not in projects_db:
        raise HTTPException(status_code=404, detail="项目不存在")

    project_info = projects_db[project_id].copy()
    project_path = os.path.join(PROJECTS_DIR, project_id)

    # 尝试读取生成的 anchors
    anchors_file = os.path.join(project_path, "intermediate", "anchors.json")
    project_info["anchors"] = []

    if os.path.exists(anchors_file):
        try:
            with open(anchors_file, "r", encoding="utf-8") as f:
                project_info["anchors"] = json.load(f)
        except Exception:
            pass  # 如果正在写入中可能报错，忽略即可
    # 添加对"interrupted"状态的处理，前端可能需要这个信息
    if project_info.get("status") == "interrupted":
        project_info["status_msg"] = project_info.get("status_msg", "服务重启时任务中断，需要重新启动")

    return project_info

# main.py 中增加以下路由
import shutil

@app.delete("/api/projects/{project_id}")
async def delete_project(project_id: str):

    # 1. 检查项目是否存在于内存数据库中
    if project_id not in projects_db:
        raise HTTPException(status_code=404, detail="项目不存在")

    try:
        # 2. 后端物理断言锁：如果是运行中，直接拒绝并报错，严控级联雪崩
        project = projects_db.get(project_id)
        if project.get("status") in ["running", "pending"]:
            raise HTTPException(
                status_code=400,
                detail="当前项目正处于大模型逻辑解析或自动编译自愈中，为防资产损坏，禁止执行物理删除！"
            )
         # 添加对"interrupted"状态的判断，允许删除中断的项目
        elif project.get("status") == "interrupted":
            logger.info(f"允许删除中断状态的项目 {project_id}")

        # 2. 获取物理路径并清理磁盘文件
        project_path = os.path.join(PROJECTS_DIR, project_id)
        if os.path.exists(project_path):
            # 使用 shutil.rmtree 递归删除整个项目文件夹（包含 inputs, intermediate 等）
            shutil.rmtree(project_path)
            logger.info(f"已清理磁盘空间: {project_path}")

        # 3. 从内存数据库中移除记录
        del projects_db[project_id]

        # 4. 持久化到磁盘 JSON 文件
        save_db()

        logger.info(f"项目 {project_id} 已成功删除")
        return {"status": "success", "message": f"Project {project_id} deleted"}

    except Exception as e:
        logger.error(f"删除项目失败: {e}")
        raise HTTPException(status_code=500, detail=f"服务器内部错误: {str(e)}")
    # =====================================================================
# --- 5. 形式化与智能体数据模型定义（核心修复区：补齐丢失的 Pydantic 模型） ---
# =====================================================================

# 1. 现有的图谱节点模型
class FormalizationNode(BaseModel):
    id: str
    type: str
    title: str
    description: str
    lean_code: str

# 2. 🟢 核心修复：补齐前端控制台专用的命令请求模型，消除 NameError
class AgentCommandRequest(BaseModel):
    project_id: str
    command: str


class AutoResumeConfig(BaseModel):
    enabled: bool


# =====================================================================
# --- 6. 核心接口：形式化图谱与控制台路由 ---
# =====================================================================


@app.get("/api/config/auto-resume")
async def get_auto_resume_config():
    return {"auto_resume_on_startup": app_config.get("auto_resume_on_startup", False)}


@app.post("/api/config/auto-resume")
async def set_auto_resume_config(config: AutoResumeConfig):
    app_config["auto_resume_on_startup"] = config.enabled
    save_config()
    return {"auto_resume_on_startup": config.enabled}


@app.get("/api/projects/{project_id}/formalization", response_model=List[FormalizationNode])
async def get_project_formalization_graph(project_id: str):
    """
    前端图谱获取中央网关
    """
    target_json = f"./artifacts/projects/{project_id}/intermediate/formalization.json"

    if not os.path.exists(target_json):
        # 物理防御：如果流水线还没跑完或失败，返回空数组，前端会显示温馨提示而不会挂起
        return []

    try:
        with open(target_json, "r", encoding="utf-8") as f:
            nodes_data = json.load(f)
            return nodes_data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"读取图谱文件失败: {str(e)}")


def _get_or_create_project_trace_node(project_id: str, agent_name: str):
    if project_id not in projects_db:
        return None
    project = projects_db[project_id]
    if "trace_nodes" not in project or not isinstance(project["trace_nodes"], list):
        project["trace_nodes"] = []

    for node in project["trace_nodes"]:
        if node.get("agent_name") == agent_name:
            if "steps" not in node or not isinstance(node["steps"], list):
                node["steps"] = []
            return node

    node = {
        "agent_name": agent_name,
        "status": "running",
        "title": agent_name,
        "compiler_error": "None",
        "steps": []
    }
    project["trace_nodes"].append(node)
    return node


def _append_project_trace_step(agent_node, title, status="running", compiler_error="None", output_code=""):
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


@app.post("/api/agent/command")
async def handle_agent_command(request: AgentCommandRequest):
    """
    智能体控制台中央接入网关
    """
    pid = request.project_id
    cmd = request.command

    if not pid or not cmd.strip():
        raise HTTPException(status_code=400, detail="Missing project_id or command")
    if pid not in projects_db:
        raise HTTPException(status_code=404, detail="项目不存在")

    trace_node = _get_or_create_project_trace_node(pid, "Console Agent")
    trace_step = _append_project_trace_step(
        trace_node,
        title=f"接收控制台命令: {cmd}",
        status="running",
        compiler_error="None",
        output_code="控制台命令已进入执行队列，正在调度 execute_agent_logic 进行处理..."
    )
    save_db()

    try:
        from pipeline.llm_agent import execute_agent_logic
        reply_msg = execute_agent_logic(pid, cmd, projects_db, save_db)

        trace_step.update({
            "status": "success",
            "title": f"命令已成功处理: {cmd}",
            "compiler_error": "None",
            "output_code": f"命令: {cmd}\n\n回复: {reply_msg if isinstance(reply_msg, str) else json.dumps(reply_msg, ensure_ascii=False)}"
        })
        trace_node["status"] = "success"
        save_db()

        return {"reply": reply_msg}

    except Exception as e:
        import traceback
        error_text = traceback.format_exc()
        trace_step.update({
            "status": "fail",
            "title": f"命令执行失败: {cmd}",
            "compiler_error": str(e),
            "output_code": error_text
        })
        trace_node["status"] = "fail"
        save_db()

        logger.error(f"控制台指令路由执行崩溃: {error_text}")
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")

@app.get("/api/logs/global")
def get_global_agent_logs(lines: int = 20):
    """
    【主页控制面板专用】打捞系统全局调度与 Pipeline 宏观流转日志
    """
    # 物理定位 loguru 生成的全局主日志文件（根据你 loguru 的配置调整路径）
    global_log_path = os.path.join(LOGS_DIR, "app.log")
    if not os.path.exists(global_log_path):
        return {"logs": ["暂无全局系统日志流。"]}

    try:
        with open(global_log_path, "r", encoding="utf-8", errors="ignore") as f:
            all_lines = f.readlines()
            # 过滤或提取包含 pipeline、agent、run_pipeline 等关键词的宏观调度日志
            macro_logs = [line.strip() for line in all_lines if "pipeline" in line or "CRITICAL" in line]
            return {"logs": macro_logs[-lines:]}
    except Exception as e:
        return {"logs": [f"全局日志物理提取异常: {str(e)}"]}

@app.get("/api/projects/{project_id}/logs")
def get_project_micro_logs(project_id: str, lines: int = 30):
    """
    【项目详情页工作区专用】精准物理隔离，捞取特定项目内部的微观大模型自愈编译细节
    """
    # 精准定位到具体项目工作区内部的日志文件
    project_log_path = os.path.join(PROJECTS_ROOT, project_id, "intermediate", "agent.log")

    # 容错：如果还没有生成局部日志，则去全局日志中动态过滤该项目 ID 的切片
    if not os.path.exists(project_log_path):
        global_log_path = os.path.join(LOGS_DIR, "app.log")
        if os.path.exists(global_log_path):
            with open(global_log_path, "r", encoding="utf-8", errors="ignore") as f:
                all_lines = f.readlines()
                # 动态打捞包含该项目 ID 的所有微观微循环日志
                project_slices = [line.strip() for line in all_lines if project_id in line]
                return {"logs": project_slices[-lines:] if project_slices else ["工作区激活成功，等待 Agent 状态机写入第一行微观日志..."]}
        return {"logs": ["暂无该项目的自愈日志资产。"]}

    try:
        with open(project_log_path, "r", encoding="utf-8", errors="ignore") as f:
            all_lines = f.readlines()
            return {"logs": [line.strip() for line in all_lines[-lines:]]}
    except Exception as e:
        return {"logs": [f"项目日志物理提取异常: {str(e)}"]}
@app.get("/api/projects/{project_id}/agent-logs")
def get_project_agent_logs(project_id: str):
    """
    【微观工作区专用】精准定位每个项目内部的 logs/agent.log 物理资产并向前端安全吐出
    """
    # 🔴 修正前：project_log_path = os.path.join(BASE_DIR, "projects", project_id, "logs", "agent.log")
    # 🟢 修正后：与 core.py 保持绝对的路径同源性，锁定 artifacts 目录
    project_log_path = os.path.join(PROJECTS_DIR, project_id, "logs", "agent.log")

    # 物理容错：如果文件夹尚未建立
    if not os.path.exists(project_log_path):
        os.makedirs(os.path.dirname(project_log_path), exist_ok=True)
        return {"logs": [f"⏳ [{project_id}] 工作区激活成功，等待 Agent 状态机写入第一行微观日志..."]}

    try:
        with open(project_log_path, "r", encoding="utf-8", errors="ignore") as f:
            all_lines = f.readlines()
            # 统一向前端返回最新的 30 行实时编译自愈 Trace
            return {"logs": [line.strip() for line in all_lines[-30:]]}
    except Exception as e:
        return {"logs": [f"项目日志物理提取异常: {str(e)}"]}
@app.get("/api/agents/global-status")
def get_global_agent_status():
    """
    【全局动态拓扑中心·物理修复版】
    直接基于 core.py 真实写入的 status_msg 状态文本进行特征工程匹配，动态判定当前掌权的 Agent
    """
    active_slots = []
    total_running = 0
    total_success = 0
    total_fail = 0

    for proj_id, info in projects_db.items():
        status = info.get("status", "pending")
        status_msg = info.get("status_msg", "等待调度...")

        if status == "running":
            total_running += 1
        elif status == "success":
            total_success += 1
        elif status == "fail":
            total_fail += 1

        # 只要项目启动过，或者已经有了状态消息，就分配卡片槽位
        if status in ["running", "success", "fail"] or status_msg != "等待调度...":

            dynamic_agent=projects_db[f"{proj_id}"]["trace_nodes"][0]["agent_name"] if "trace_nodes" in info and isinstance(info["trace_nodes"], list) and len(info["trace_nodes"]) > 0 else dynamic_agent

            active_slots.append({
                "project_id": proj_id,
                "project_name": info.get("name", "未命名项目"),
                "status": status,
                "active_agent": dynamic_agent,  # 动态计算出的当前负责 Agent
                "status_msg": status_msg
            })

    # 让正在高频跑的项目始终置顶展示
    active_slots.sort(key=lambda x: 0 if x["status"] == "running" else 1)

    return {
        "summary": {
            "running_slots": total_running,
            "success_count": total_success,
            "fail_count": total_fail
        },
        "slots": active_slots[:6]
    }
@app.get("/api/projects/{project_id}/theorem-manifest")
def get_project_theorem_manifest(project_id: str):
    """
    【主定理沙箱专用】从项目中间产物中物理提取 core_theorem_manifest.json 核心资产
    """
    # 1. 物理定位到该项目专属的成果清单路径
    # 使用全局定义的 PROJECTS_DIR（artifacts/projects）以确保路径对齐
    manifest_path = os.path.join(PROJECTS_DIR, project_id, "intermediate", "core_theorem_manifest.json")
    
    # 2. 物理容错：如果文件还未生成（证明编译自愈或定理提取 Agent 尚未结束）
    if not os.path.exists(manifest_path):
        return {
            "has_manifest": False,
            "msg": "⏳ 核心定理提取 Agent 仍在深度分析或正在进行 LaTeX 编译自愈，请稍后..."
        }
    
    # 3. 安全读取并向前端吐出 JSON 树
    try:
        with open(manifest_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            # 兼容两种格式：如果文件直接就是 main_theorem 内容，直接返回；
            # 如果文件用了包装 {"main_theorem": {...}}，则取其中字段。
            manifest = data.get("main_theorem") if isinstance(data, dict) and "main_theorem" in data else data
            return {
                "has_manifest": True,
                "manifest": manifest or {}
            }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"成果图谱物理读取破损: {str(e)}"
        )
    
@app.get("/api/project/{project_id}")
async def get_project_detail(project_id: str):
    if project_id not in projects_db:
        raise HTTPException(status_code=404, detail="项目不存在")
    
    project_info = projects_db[project_id]
    
    # 🎯 核心技术契约：向下游前端吐出战时直播的 trace_nodes 拓扑数组
    return {
        "id": project_id,
        "name": project_info.get("name", "未命名项目"),
        "status": project_info.get("status", "pending"),
        "status_msg": project_info.get("status_msg", "等待中"),
        "trace_nodes": project_info.get("trace_nodes", [])  # 💥 就是这一行
    }