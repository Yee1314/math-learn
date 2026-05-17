import os
import json
import subprocess
from loguru import logger
from pipeline.llm_agent import fix_latex_with_trace


def compile_with_auto_healing(project_id, work_dir, tex_path, model, db_ref, max_retries=2):
    """
    使用 xelatex 编译 tex 文件并在失败时调用 Auto-Healing Agent 进行修复。

    返回 True 表示编译成功，返回 False 表示所有重试与自愈均失败。
    """
    for attempt in range(max_retries + 1):
        logger.info(f"第 {attempt+1} 次编译尝试...")

        try:
            res = subprocess.run(
                ['xelatex', '-interaction=nonstopmode', 'main.tex'],
                cwd=work_dir,
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='ignore',
                timeout=300,
            )
        except Exception as e:
            # OS 级别错误，例如 xelatex 未安装 或 权限问题
            logger.exception("编译过程中发生异常")
            exc_msg = str(e)
            try:
                with open(tex_path, 'r', encoding='utf-8') as f:
                    current_code = f.read()
            except Exception:
                current_code = ""

            try:
                fix_latex_with_trace(project_id, current_code, f"OS error: {exc_msg}", model, db_ref=db_ref)
            except Exception:
                logger.exception("在记录自愈轨迹时发生异常")

            if attempt >= max_retries:
                # 标记项目失败，调用者负责持久化 db_ref
                try:
                    if isinstance(db_ref, dict) and project_id in db_ref:
                        db_ref[project_id]['status'] = 'fail'
                        db_ref[project_id]['current_step'] = 'compiling'
                        db_ref[project_id]['status_msg'] = 'LaTeX 编译失败或 xelatex 未安装。自愈尝试已结束。'
                except Exception:
                    logger.exception('设置 db_ref 失败')
                return False
            # 否则继续下一次尝试
            continue

        # 如果 res 可用，检查返回码
        stdout_log = res.stdout or ''
        stderr_log = res.stderr or ''
        full_log = stdout_log + stderr_log

        if res.returncode == 0:
            logger.success(f"第 {attempt+1} 次编译成功！")
            return True

        # 非零返回码，准备自愈（如果还有重试机会）
        error_log = full_log[-1500:] if full_log else '编译器未生成有效日志输出'

        if attempt < max_retries:
            logger.warning('编译失败，正在准备自愈数据...')
            try:
                with open(tex_path, 'r', encoding='utf-8') as f:
                    current_code = f.read()
            except Exception:
                current_code = ''

            try:
                fixed_code = fix_latex_with_trace(project_id, current_code, error_log, model, db_ref=db_ref)
                with open(tex_path, 'w', encoding='utf-8') as f:
                    f.write(fixed_code)
            except Exception:
                logger.exception('自愈调用失败')
            # 进入下一次循环以尝试重新编译
            continue
        else:
            # 最后一轮自愈已用尽
            logger.error('自愈失败，已达到最大重试次数')
            try:
                # 将最后的错误也记录到 trace
                with open(tex_path, 'r', encoding='utf-8') as f:
                    current_code = f.read()
            except Exception:
                current_code = ''
            try:
                fix_latex_with_trace(project_id, current_code, error_log, model, db_ref=db_ref)
            except Exception:
                logger.exception('记录最终自愈失败时出错')
            try:
                if isinstance(db_ref, dict) and project_id in db_ref:
                    db_ref[project_id]['status'] = 'fail'
                    db_ref[project_id]['current_step'] = 'compiling'
                    db_ref[project_id]['status_msg'] = 'LaTeX 编译失败，自愈尝试已达上限。'
            except Exception:
                logger.exception('设置 db_ref 失败')
            return False

    # 循环外默认失败
    return False

