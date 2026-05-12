from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...core.deps import get_current_user
from ...models.user import User
from ...schemas.journal import (
    ReadinessResponse,
    ReadinessUpdate,
    TrainingSessionCreate,
    TrainingSessionResponse,
    TrainingSessionUpdate,
    WeaknessPatternResponse,
)
from ...services import journal_service

router = APIRouter(prefix="/journal", tags=["journal"])


@router.get("/sessions", response_model=list[TrainingSessionResponse])
async def get_sessions(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await journal_service.get_sessions(db, current_user.id)


@router.post("/sessions", response_model=TrainingSessionResponse, status_code=201)
async def add_session(
    data: TrainingSessionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await journal_service.add_session(db, current_user.id, data)


@router.put("/sessions/{session_id}", response_model=TrainingSessionResponse)
async def update_session(
    session_id: int,
    data: TrainingSessionUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    updated = await journal_service.update_session(db, current_user.id, session_id, data)
    if not updated:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found",
        )
    return updated


@router.delete("/sessions/{session_id}", status_code=204)
async def delete_session(
    session_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    deleted = await journal_service.delete_session(db, current_user.id, session_id)
    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found",
        )


@router.get("/weaknesses", response_model=list[WeaknessPatternResponse])
async def get_weaknesses(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await journal_service.get_weaknesses(db, current_user.id)


@router.get("/readiness", response_model=ReadinessResponse)
async def get_readiness(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await journal_service.get_readiness(db, current_user.id)


@router.put("/readiness", response_model=ReadinessResponse)
async def update_readiness(
    data: ReadinessUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return await journal_service.update_readiness(db, current_user.id, data)
