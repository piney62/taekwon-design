from datetime import datetime
from typing import Optional

from sqlalchemy import ForeignKey, Text
from sqlalchemy.orm import Mapped, mapped_column

from ..core.database import Base


class PoseAnalysisRecord(Base):
    __tablename__ = "pose_analysis_records"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    tul_name: Mapped[str] = mapped_column()
    tul_display_name: Mapped[str] = mapped_column()
    movement_no: Mapped[int] = mapped_column()
    movement_name: Mapped[str] = mapped_column()
    score: Mapped[Optional[int]] = mapped_column(nullable=True)
    feedback: Mapped[str] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
