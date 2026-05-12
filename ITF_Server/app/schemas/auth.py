from typing import Optional

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: Optional[EmailStr] = None
    display_name: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=4)
    role: str = "student"                          # 'student' | 'instructor'
    belt_level: Optional[str] = Field(None, max_length=20)   # student only
    training_start_year: Optional[int] = None      # student only
    dojo_name: Optional[str] = Field(None, max_length=100)   # instructor only
    dan_rank: Optional[str] = Field(None, max_length=20)     # instructor only


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str
