from datetime import datetime, timezone

from sqlalchemy import DateTime, Integer, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column

from ..core.database import Base


class PatternImageVersion(Base):
    __tablename__ = "pattern_image_versions"
    __table_args__ = (
        UniqueConstraint("faction", "slug", name="uq_faction_slug"),
    )

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    faction: Mapped[str] = mapped_column(String(20), default="vienna", index=True)
    slug: Mapped[str] = mapped_column(String(30), index=True)
    version: Mapped[int] = mapped_column(Integer, default=1)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
