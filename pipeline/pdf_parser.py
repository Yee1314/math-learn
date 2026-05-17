import re
import os
import json
import pdfplumber
from loguru import logger

def parse_pdf_to_pages(pdf_path, output_dir):
    anchors = []
    
    # 1. 增强型正则表达式
    # 匹配章节：例如 "2 Generating functions" 或 "2.1 Preliminaries"
    sec_pattern = re.compile(r'^(\d+(\.\d+)*)\s+([A-Z].*)')
    # 匹配数学实体：例如 "Theorem 1.1", "Lemma 2.3", "Definition 2.1"
    entity_pattern = re.compile(r'^(Theorem|Lemma|Definition|Corollary|Proposition|Remark)\s+\d+(\.\d+)*', re.IGNORECASE)
    # 匹配证明开始
    proof_pattern = re.compile(r'^Proof\.', re.IGNORECASE)

    current_section_id = "0"
    current_section_title = "Front Matter"

    with pdfplumber.open(pdf_path) as pdf:
        for i, page in enumerate(pdf.pages):
            text = page.extract_text()
            if not text: continue
            
            # 2. 细颗粒度行扫描，而不是简单的双换行拆分
            lines = text.split('\n')
            temp_snippet = []
            
            def save_anchor(content, p_idx, s_idx):
                if len(content.strip()) < 10: return
                anchors.append({
                    "en_anchor_id": f"p{p_idx+1}_s{s_idx}",
                    "page": p_idx + 1,
                    "section_id": current_section_id,
                    "section_title": current_section_title,
                    "snippet": content.strip()
                })

            for line_idx, line in enumerate(lines):
                stripped_line = line.strip()
                
                # 检测是否是新章节
                sec_match = sec_pattern.match(stripped_line)
                # 检测是否是新数学实体
                ent_match = entity_pattern.match(stripped_line)
                # 检测是否是证明开始
                proof_match = proof_pattern.match(stripped_line)

                # 如果遇到标题或重要实体开头，且缓存中有内容，先保存上一个块
                if (sec_match or ent_match or proof_match) and temp_snippet:
                    save_anchor("\n".join(temp_snippet), i, line_idx)
                    temp_snippet = []

                # 更新当前章节状态
                if sec_match:
                    current_section_id = sec_match.group(1)
                    current_section_title = stripped_line
                
                temp_snippet.append(line)

            # 每一页结束时，保存剩余内容
            if temp_snippet:
                save_anchor("\n".join(temp_snippet), i, 999)
                temp_snippet = []
                
    # 3. 持久化存储
    output_path = os.path.join(output_dir, "anchors.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(anchors, f, ensure_ascii=False, indent=2)
    
    logger.success(f"解析完成，共生成 {len(anchors)} 个逻辑锚点")
    return len(pdf.pages)