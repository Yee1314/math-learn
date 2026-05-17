import re
import json
import subprocess
from loguru import logger
# 假设你已经有了一个用于调用 LLM 的函数，例如 call_llm(prompt)
# from backend.utils.llm import call_llm 

class FormalizationAgent:
    def __init__(self, project_id, latex_source):
        self.project_id = project_id
        self.source = latex_source
        self.dag = {"definitions": [], "lemmas": [], "theorem": None}
        self.lean_code = ""
        self.max_retries = 3

    def extract_structure(self):
        """第一步：双式逻辑抽取，将 LaTeX 拆解为分层 DAG"""
        logger.info(f"[{self.project_id}] 开始解析 LaTeX 逻辑结构...")
        
        # 1. 提取基础定义
        defs = re.findall(r'\\begin{definition}(.*?)\\end{definition}', self.source, re.S)
        for i, d in enumerate(defs):
            self.dag["definitions"].append({
                "id": f"def_{i+1}",
                "type": "Definition",
                "title": f"基础定义 {i+1}",
                "latex": d.strip()
            })

        # 2. 提取引理 (子步骤)
        lemmas = re.findall(r'\\begin{lemma}(.*?)\\end{lemma}', self.source, re.S)
        for i, l in enumerate(lemmas):
            self.dag["lemmas"].append({
                "id": f"lemma_{i+1}",
                "type": "Lemma",
                "title": f"核心引理 {i+1}",
                "latex": l.strip()
            })

        # 3. 提取主定理与证明
        theorem_match = re.search(r'\\begin{theorem}(.*?)\\end{theorem}', self.source, re.S)
        proof_match = re.search(r'\\begin{proof}(.*?)\\end{proof}', self.source, re.S)
        
        if theorem_match and proof_match:
             self.dag["theorem"] = {
                "id": "main_theorem",
                "type": "Theorem",
                "title": "主定理 (收敛性)",
                "latex_statement": theorem_match.group(1).strip(),
                "latex_proof": proof_match.group(1).strip()
             }
        
        self._generate_initial_lean()
        return self.dag

    def _generate_initial_lean(self):
        """第二步：让 Agent 根据 DAG 生成初始 Lean 4 代码"""
        prompt = f"""
        将以下 LaTeX 证明结构转换为 Lean 4 代码。
        要求：
        1. 必须使用 tactic mode (by ...)。
        2. 将证明分为多个子步骤 (have ... := ...)。
        3. 请只输出 Lean 源码，不要包含其他解释。
        
        数据：
        {json.dumps(self.dag, ensure_ascii=False)}
        """
        # self.lean_code = call_llm(prompt)
        # 这里用伪代码模拟生成的初始 Lean 骨架
        self.lean_code = """
import Mathlib.Topology.MetricSpace.Basic

theorem mri_convergence (H : Matrix) : Convergent := by
  sorry
"""
        self._save_lean_file()

    def _save_lean_file(self):
        # 将代码保存到 artifacts 目录
        filepath = f"artifacts/projects/{self.project_id}/formal/main.lean"
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(self.lean_code.strip())

    def auto_heal_loop(self):
        """第三步：Lean 自动修复闭环 (Auto-Healing)"""
        filepath = f"artifacts/projects/{self.project_id}/formal/main.lean"
        
        for attempt in range(1, self.max_retries + 1):
            logger.info(f"[{self.project_id}] 第 {attempt} 次编译尝试...")
            
            # 调用 Lean 编译器
            result = subprocess.run(["lean", filepath], capture_output=True, text=True)
            
            if result.returncode == 0:
                logger.success(f"[{self.project_id}] 第 {attempt} 次编译成功！")
                return True
                
            error_trace = result.stderr
            logger.warning(f"编译失败，Trace:\n{error_trace}")
            
            # Agent 根据 Trace 修复代码
            repair_prompt = f"""
            以下 Lean 4 代码编译失败。
            错误日志 (Trace):
            {error_trace}
            
            当前代码:
            {self.lean_code}
            
            请修复代码中的错误并返回完整的、修复后的 Lean 4 代码。只返回代码。
            """
            # self.lean_code = call_llm(repair_prompt)
            # 这里模拟修复成功
            self.lean_code = self.lean_code.replace("sorry", "exact rfl")
            self._save_lean_file()
            
        logger.error("自动修复失败，达到最大重试次数。")
        return False