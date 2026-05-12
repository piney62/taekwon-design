from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field


class InviteCodeResponse(BaseModel):
    id: int
    code: str
    status: str
    expires_at: datetime
    used_at: Optional[datetime]
    created_at: datetime

    model_config = {"from_attributes": True}


class UseCodeRequest(BaseModel):
    code: str


class MemberResponse(BaseModel):
    student_id: int
    display_name: str
    belt_level: str
    training_start_year: Optional[int]
    connected_at: str


class CommentCreate(BaseModel):
    student_id: int
    content: str = Field(max_length=500)


class CommentUpdate(BaseModel):
    content: str = Field(max_length=500)


class CommentResponse(BaseModel):
    id: int
    instructor_id: int
    student_id: int
    content: str
    is_read: bool
    read_at: Optional[datetime]
    edited_at: Optional[datetime]
    deleted_at: Optional[datetime]
    created_at: datetime

    model_config = {"from_attributes": True}


class HomeworkCreate(BaseModel):
    student_id: int
    content: str = Field(max_length=200)
    due_date: date


class HomeworkResponse(BaseModel):
    id: int
    instructor_id: int
    student_id: int
    content: str
    due_date: date
    status: str
    completed_at: Optional[datetime]
    completed_by: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}
