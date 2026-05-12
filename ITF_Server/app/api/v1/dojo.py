from datetime import date, datetime, timedelta, timezone

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...core.deps import get_current_user
from ...models.user import User
from ...schemas.dojo import (
    CommentCreate,
    CommentResponse,
    CommentUpdate,
    HomeworkCreate,
    HomeworkResponse,
    InviteCodeResponse,
    MemberResponse,
)
from ...services import dojo_service

router = APIRouter(prefix="/dojo", tags=["dojo"])


# ── Invite codes ──────────────────────────────────────────────────────────────

@router.post("/invite-codes", response_model=InviteCodeResponse, status_code=201)
async def create_code(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.create_invite_code(db, current_user.id)


@router.get("/invite-codes", response_model=list[InviteCodeResponse])
async def list_codes(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.list_invite_codes(db, current_user.id)


@router.delete("/invite-codes/{code}", status_code=204)
async def revoke_code(
    code: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await dojo_service.revoke_invite_code(db, current_user.id, code.upper())


@router.post("/invite-codes/{code}/use", status_code=200)
async def use_code(
    code: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    member = await dojo_service.use_invite_code(db, current_user.id, code.upper())
    return {"connected": True, "instructor_id": member.instructor_id}


# ── Members ───────────────────────────────────────────────────────────────────

@router.get("/members", response_model=list[MemberResponse])
async def get_members(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.list_members(db, current_user.id)


@router.get("/members/{student_id}")
async def get_member_detail(
    student_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.get_member_detail(db, current_user.id, student_id)


@router.get("/members/{student_id}/journal")
async def get_student_journal(
    student_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.get_student_journal(db, current_user.id, student_id)


@router.delete("/members/{student_id}", status_code=204)
async def remove_member(
    student_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await dojo_service.disconnect_student(db, current_user.id, student_id)


@router.delete("/connection", status_code=204)
async def leave_dojo(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await dojo_service.student_disconnect(db, current_user.id)


# ── Comments ──────────────────────────────────────────────────────────────────

@router.post("/comments", response_model=CommentResponse, status_code=201)
async def create_comment(
    body: CommentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.create_comment(db, current_user.id, body.student_id, body.content)


@router.patch("/comments/{comment_id}", response_model=CommentResponse)
async def update_comment(
    comment_id: int,
    body: CommentUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.update_comment(db, current_user.id, comment_id, body.content)


@router.delete("/comments/{comment_id}", status_code=204)
async def delete_comment(
    comment_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await dojo_service.delete_comment(db, current_user.id, comment_id)


@router.patch("/comments/{comment_id}/read", status_code=204)
async def mark_read(
    comment_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await dojo_service.mark_comment_read(db, current_user.id, comment_id)


@router.get("/comments/student/{student_id}", response_model=list[CommentResponse])
async def list_comments(
    student_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.list_comments(db, current_user.id, student_id)


# ── Homework ──────────────────────────────────────────────────────────────────

@router.post("/homework/group", status_code=201)
async def create_group_homework(
    body: HomeworkCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    count = await dojo_service.create_group_homework(
        db, current_user.id, body.content, body.due_date
    )
    return {"assigned_count": count}


@router.post("/homework", response_model=HomeworkResponse, status_code=201)
async def create_homework(
    body: HomeworkCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.create_homework(
        db, current_user.id, body.student_id, body.content, body.due_date
    )


@router.patch("/homework/{homework_id}/complete", response_model=HomeworkResponse)
async def complete_homework(
    homework_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.complete_homework(db, current_user.id, homework_id)


@router.get("/stats")
async def get_dojo_stats(
    start_date: str | None = Query(default=None),
    end_date: str | None = Query(default=None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    now = datetime.now(timezone.utc)
    if start_date:
        sd = date.fromisoformat(start_date)
    else:
        sd = date(now.year, now.month, 1)
    if end_date:
        ed = date.fromisoformat(end_date)
    else:
        next_month_first = date(now.year + (now.month // 12), (now.month % 12) + 1, 1)
        ed = next_month_first - timedelta(days=1)
    return await dojo_service.get_dojo_stats(db, current_user.id, sd, ed)


@router.get("/homework-stats")
async def get_homework_stats(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.get_homework_stats(db, current_user.id)


@router.get("/homework/mine", response_model=list[HomeworkResponse])
async def my_homework(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.list_pending_homework(db, current_user.id, current_user.id)


@router.get("/homework/pending/{student_id}", response_model=list[HomeworkResponse])
async def list_pending_homework(
    student_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    return await dojo_service.list_pending_homework(db, current_user.id, student_id)
