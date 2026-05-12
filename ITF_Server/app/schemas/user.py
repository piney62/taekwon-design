from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class UserResponse(BaseModel):
    id: int
    username: str
    display_name: str
    role: str
    belt_level: str
    language_code: str
    ai_provider: str
    training_start_year: Optional[int]
    student_plan: str
    dojo_connected: bool
    instructor_name: str
    homework_text: str
    dojo_name: Optional[str]
    dan_rank: Optional[str]
    dojo_plan: str
    avatar_url: Optional[str] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class UpdateUserRequest(BaseModel):
    display_name: str | None = Field(None, min_length=1, max_length=100)
    belt_level: str | None = None
    language_code: str | None = None
    ai_provider: str | None = None


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(min_length=4)
