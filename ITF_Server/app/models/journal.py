from datetime import date, datetime, timezone

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from ..core.database import Base


class TrainingSession(Base):
    __tablename__ = "training_sessions"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    session_date: Mapped[date] = mapped_column(Date)
    duration_minutes: Mapped[int] = mapped_column(Integer)
    training_type: Mapped[str] = mapped_column(String(30))
    score: Mapped[int] = mapped_column(Integer)  # 1-5
    notes: Mapped[str] = mapped_column(Text, default="")
    is_auto_saved: Mapped[bool] = mapped_column(Boolean, default=False)
    instructor_comment: Mapped[str] = mapped_column(Text, default="")
    pattern_name: Mapped[str] = mapped_column(String(50), default="")
    selected_movements: Mapped[str] = mapped_column(Text, default="", server_default="")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
    )


class WeaknessPattern(Base):
    __tablename__ = "weakness_patterns"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    movement_name: Mapped[str] = mapped_column(String(100))
    consecutive_count: Mapped[int] = mapped_column(Integer, default=1)
    detected_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
    )


class PromotionReadiness(Base):
    __tablename__ = "promotion_readiness"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    sparring_check: Mapped[bool] = mapped_column(Boolean, default=False)
    breaking_check: Mapped[bool] = mapped_column(Boolean, default=False)
    theory_test_passed: Mapped[bool] = mapped_column(Boolean, default=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
    )
