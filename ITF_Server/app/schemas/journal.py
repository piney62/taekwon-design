from datetime import date, datetime

from pydantic import BaseModel, Field


class TrainingSessionCreate(BaseModel):
    session_date: date
    duration_minutes: int = Field(ge=1)
    training_type: str
    score: int = Field(ge=1, le=5)
    notes: str = ""
    is_auto_saved: bool = False
    instructor_comment: str = ""
    pattern_name: str = ""
    selected_movements: str = ""


class TrainingSessionResponse(BaseModel):
    id: int
    session_date: date
    duration_minutes: int
    training_type: str
    score: int
    notes: str
    is_auto_saved: bool
    instructor_comment: str
    pattern_name: str
    selected_movements: str = ""
    created_at: datetime

    model_config = {"from_attributes": True}


class WeaknessPatternResponse(BaseModel):
    id: int
    movement_name: str
    consecutive_count: int
    detected_at: datetime

    model_config = {"from_attributes": True}


class ReadinessResponse(BaseModel):
    sparring_check: bool
    breaking_check: bool
    theory_test_passed: bool

    model_config = {"from_attributes": True}


class TrainingSessionUpdate(BaseModel):
    session_date: date
    duration_minutes: int = Field(ge=1)
    training_type: str
    score: int = Field(ge=1, le=5)
    notes: str = ""
    pattern_name: str = ""
    selected_movements: str = ""


class ReadinessUpdate(BaseModel):
    sparring_check: bool
    breaking_check: bool
    theory_test_passed: bool = False
