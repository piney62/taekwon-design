from datetime import datetime, timezone

from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.journal import PromotionReadiness, TrainingSession, WeaknessPattern
from ..schemas.journal import ReadinessUpdate, TrainingSessionCreate, TrainingSessionUpdate

_WEAKNESS_THRESHOLD = 70  # scores below this mark a movement as weak


async def get_sessions(
    db: AsyncSession, user_id: int
) -> list[TrainingSession]:
    result = await db.execute(
        select(TrainingSession)
        .where(TrainingSession.user_id == user_id)
        .order_by(TrainingSession.session_date.desc())
    )
    return list(result.scalars().all())


async def add_session(
    db: AsyncSession, user_id: int, data: TrainingSessionCreate
) -> TrainingSession:
    session = TrainingSession(user_id=user_id, **data.model_dump())
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session


async def update_session(
    db: AsyncSession, user_id: int, session_id: int, data: TrainingSessionUpdate
) -> TrainingSession | None:
    result = await db.execute(
        select(TrainingSession).where(
            TrainingSession.id == session_id,
            TrainingSession.user_id == user_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        return None
    session.session_date = data.session_date
    session.duration_minutes = data.duration_minutes
    session.training_type = data.training_type
    session.score = data.score
    session.notes = data.notes
    session.pattern_name = data.pattern_name
    session.selected_movements = data.selected_movements
    await db.commit()
    await db.refresh(session)
    return session


async def delete_session(
    db: AsyncSession, user_id: int, session_id: int
) -> bool:
    result = await db.execute(
        delete(TrainingSession).where(
            TrainingSession.id == session_id,
            TrainingSession.user_id == user_id,
        )
    )
    await db.commit()
    return result.rowcount > 0


async def get_weaknesses(
    db: AsyncSession, user_id: int
) -> list[WeaknessPattern]:
    result = await db.execute(
        select(WeaknessPattern)
        .where(WeaknessPattern.user_id == user_id)
        .order_by(WeaknessPattern.consecutive_count.desc())
    )
    return list(result.scalars().all())


async def record_pose_weakness(
    db: AsyncSession, user_id: int, movement_name: str, score: int
) -> None:
    """
    Called after every pose analysis.
    - score < threshold → upsert weakness (consecutive_count +1)
    - score >= threshold → decrement consecutive_count; remove row when it reaches 0
    """
    result = await db.execute(
        select(WeaknessPattern).where(
            WeaknessPattern.user_id == user_id,
            WeaknessPattern.movement_name == movement_name,
        )
    )
    row = result.scalar_one_or_none()

    if score < _WEAKNESS_THRESHOLD:
        now = datetime.now(timezone.utc)
        if row is None:
            db.add(WeaknessPattern(
                user_id=user_id,
                movement_name=movement_name,
                consecutive_count=1,
                detected_at=now,
            ))
        else:
            row.consecutive_count += 1
            row.detected_at = now
    else:
        if row is not None:
            if row.consecutive_count <= 1:
                await db.delete(row)
            else:
                row.consecutive_count -= 1

    await db.commit()


async def get_readiness(
    db: AsyncSession, user_id: int
) -> PromotionReadiness:
    result = await db.execute(
        select(PromotionReadiness).where(PromotionReadiness.user_id == user_id)
    )
    r = result.scalar_one_or_none()
    if r is None:
        r = PromotionReadiness(user_id=user_id)
        db.add(r)
        await db.commit()
        await db.refresh(r)
    return r


async def update_readiness(
    db: AsyncSession, user_id: int, data: ReadinessUpdate
) -> PromotionReadiness:
    r = await get_readiness(db, user_id)
    r.sparring_check = data.sparring_check
    r.breaking_check = data.breaking_check
    r.theory_test_passed = data.theory_test_passed
    r.updated_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(r)
    return r
