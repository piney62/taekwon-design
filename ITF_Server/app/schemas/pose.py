from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class PoseAnalysisResponse(BaseModel):
    feedback: str
    master_stick: str
    student_stick: str
    master_angles: dict[str, float]
    student_angles: dict[str, float]
    score: int = 0
    tul_list: list[str] = []


class PoseRecordResponse(BaseModel):
    id: int
    tul_name: str
    tul_display_name: str
    movement_no: int
    movement_name: str
    score: Optional[int] = None
    feedback: str
    created_at: datetime

    model_config = {"from_attributes": True}


class PoseRecordsPage(BaseModel):
    records: list[PoseRecordResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


class PoseRecordSave(BaseModel):
    tul_name: str
    movement_no: int
    movement_name: str
    score: int
    feedback: str
