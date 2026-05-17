from pydantic import BaseModel
from typing import List, Optional

class Anchor(BaseModel):
    en_anchor_id: str  # 格式如: p1_h123abc
    page: int
    snippet: str      # 英文原文片段

class ExtractedItem(BaseModel):
    kind: str         # "Theorem", "Definition", "Proof"
    name: Optional[str] 
    statement_en: str
    statement_zh: str
    en_anchor_id: str

class ProofStep(BaseModel):
    step_id: str
    text_zh: str
    en_anchor_id: str
    dependencies: List[str] = [] # 依赖的其他 step_id