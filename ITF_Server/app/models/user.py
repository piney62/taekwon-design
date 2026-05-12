from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import Boolean, DateTime, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from ..core.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    email: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True, index=True)
    display_name: Mapped[str] = mapped_column(String(100))
    hashed_password: Mapped[str] = mapped_column(String(255))
    # role: 'student' | 'instructor'
    role: Mapped[str] = mapped_column(String(20), default="student")
    belt_level: Mapped[str] = mapped_column(String(20), default="white")
    language_code: Mapped[str] = mapped_column(String(5), default="ko")
    ai_provider: Mapped[str] = mapped_column(String(20), default="groq")
    # student fields
    training_start_year: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    dojo_connected: Mapped[bool] = mapped_column(Boolean, default=False)
    instructor_name: Mapped[str] = mapped_column(String(100), default="")
    homework_text: Mapped[str] = mapped_column(Text, default="")
    # student plan: 'free' | 'paid' ($4.99/month)
    student_plan: Mapped[str] = mapped_column(String(20), default="free")
    # instructor fields
    dojo_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    dan_rank: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    dojo_plan: Mapped[str] = mapped_column(String(20), default="free")
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
    )
