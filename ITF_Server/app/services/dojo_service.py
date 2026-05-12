import random
from datetime import date, datetime, timedelta, timezone

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..models.dojo import DojoMember, Homework, InstructorComment, InviteCode
from ..models.journal import PromotionReadiness, TrainingSession, WeaknessPattern
from ..models.user import User

_CODE_CHARS = "ABCDEFGHJKMNPQRSTUVWXYZ23456789"


def _gen_code() -> str:
    return "".join(random.choices(_CODE_CHARS, k=5))


async def _get_instructor(db: AsyncSession, user_id: int) -> User:
    user = await db.get(User, user_id)
    if user is None or user.role != "instructor":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Instructor only")
    return user


# ── Invite codes ──────────────────────────────────────────────────────────────

async def create_invite_code(db: AsyncSession, instructor_id: int) -> InviteCode:
    await _get_instructor(db, instructor_id)

    # max 5 active codes per instructor
    active = await db.execute(
        select(InviteCode).where(
            InviteCode.instructor_id == instructor_id,
            InviteCode.status == "active",
        )
    )
    if len(active.scalars().all()) >= 5:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 5 active codes allowed",
        )

    for _ in range(20):
        code_str = _gen_code()
        existing = await db.execute(select(InviteCode).where(InviteCode.code == code_str))
        if existing.scalar_one_or_none() is None:
            break
    else:
        raise HTTPException(status_code=500, detail="Could not generate unique code")

    code = InviteCode(
        code=code_str,
        instructor_id=instructor_id,
        expires_at=datetime.now(timezone.utc) + timedelta(hours=48),
    )
    db.add(code)
    await db.commit()
    await db.refresh(code)
    return code


async def list_invite_codes(db: AsyncSession, instructor_id: int) -> list[InviteCode]:
    await _get_instructor(db, instructor_id)
    now = datetime.now(timezone.utc)
    # expire overdue codes
    result = await db.execute(
        select(InviteCode).where(
            InviteCode.instructor_id == instructor_id,
            InviteCode.status == "active",
            InviteCode.expires_at < now,
        )
    )
    for c in result.scalars().all():
        c.status = "expired"
    await db.commit()

    result = await db.execute(
        select(InviteCode).where(InviteCode.instructor_id == instructor_id)
    )
    return result.scalars().all()


async def revoke_invite_code(db: AsyncSession, instructor_id: int, code_str: str) -> None:
    await _get_instructor(db, instructor_id)
    result = await db.execute(
        select(InviteCode).where(
            InviteCode.code == code_str,
            InviteCode.instructor_id == instructor_id,
        )
    )
    code = result.scalar_one_or_none()
    if code is None:
        raise HTTPException(status_code=404, detail="Code not found")
    code.status = "expired"
    await db.commit()


async def use_invite_code(db: AsyncSession, student_id: int, code_str: str) -> DojoMember:
    student = await db.get(User, student_id)
    if student is None or student.role != "student":
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Student only")

    # check student not already connected
    existing_member = await db.execute(
        select(DojoMember).where(
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    if existing_member.scalar_one_or_none() is not None:
        raise HTTPException(status_code=400, detail="Already connected to a dojo")

    now = datetime.now(timezone.utc)
    result = await db.execute(select(InviteCode).where(InviteCode.code == code_str))
    code = result.scalar_one_or_none()
    if code is None or code.status != "active" or code.expires_at < now:
        raise HTTPException(status_code=400, detail="Invalid or expired code")

    instructor = await db.get(User, code.instructor_id)
    if instructor is None:
        raise HTTPException(status_code=400, detail="Instructor not found")

    # mark code used
    code.status = "used"
    code.used_by = student_id
    code.used_at = now

    # create membership
    member = DojoMember(instructor_id=code.instructor_id, student_id=student_id)
    db.add(member)

    # update student's dojo_connected + instructor_name
    student.dojo_connected = True
    student.instructor_name = instructor.display_name

    await db.commit()
    await db.refresh(member)
    return member


# ── Members ───────────────────────────────────────────────────────────────────

async def list_members(db: AsyncSession, instructor_id: int) -> list[dict]:
    await _get_instructor(db, instructor_id)
    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.status == "active",
        )
    )
    members = result.scalars().all()
    out = []
    for m in members:
        student = await db.get(User, m.student_id)
        if student:
            out.append({
                "student_id": student.id,
                "display_name": student.display_name,
                "belt_level": student.belt_level,
                "training_start_year": student.training_start_year,
                "connected_at": m.connected_at.isoformat(),
            })
    return out


async def disconnect_student(db: AsyncSession, instructor_id: int, student_id: int) -> None:
    await _get_instructor(db, instructor_id)
    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    member = result.scalar_one_or_none()
    if member is None:
        raise HTTPException(status_code=404, detail="Member not found")

    member.status = "disconnected"
    member.disconnected_at = datetime.now(timezone.utc)
    member.disconnected_by = "instructor"

    student = await db.get(User, student_id)
    if student:
        student.dojo_connected = False
        student.instructor_name = ""
        student.homework_text = ""

    await db.commit()


async def student_disconnect(db: AsyncSession, student_id: int) -> None:
    student = await db.get(User, student_id)
    if student is None or student.role != "student":
        raise HTTPException(status_code=403, detail="Student only")

    result = await db.execute(
        select(DojoMember).where(
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    member = result.scalar_one_or_none()
    if member is None:
        raise HTTPException(status_code=404, detail="No active connection")

    member.status = "disconnected"
    member.disconnected_at = datetime.now(timezone.utc)
    member.disconnected_by = "student"

    student.dojo_connected = False
    student.instructor_name = ""
    student.homework_text = ""

    await db.commit()


async def get_member_detail(db: AsyncSession, instructor_id: int, student_id: int) -> dict:
    await _get_instructor(db, instructor_id)
    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    member = result.scalar_one_or_none()
    if member is None:
        raise HTTPException(status_code=404, detail="Member not found")

    student = await db.get(User, student_id)
    if student is None:
        raise HTTPException(status_code=404, detail="Student not found")

    # pending homework count
    hw_result = await db.execute(
        select(Homework).where(
            Homework.student_id == student_id,
            Homework.instructor_id == instructor_id,
            Homework.status == "pending",
        )
    )
    pending_hw = hw_result.scalars().all()

    # completed homework (most recent 10)
    completed_hw_result = await db.execute(
        select(Homework)
        .where(
            Homework.student_id == student_id,
            Homework.instructor_id == instructor_id,
            Homework.status == "completed",
        )
        .order_by(Homework.completed_at.desc())
        .limit(10)
    )
    completed_hw = completed_hw_result.scalars().all()

    return {
        "student_id": student.id,
        "display_name": student.display_name,
        "belt_level": student.belt_level,
        "training_start_year": student.training_start_year,
        "connected_at": member.connected_at.isoformat(),
        "pending_homework_count": len(pending_hw),
        "pending_homework": [
            {
                "id": h.id,
                "content": h.content,
                "due_date": h.due_date.isoformat() if h.due_date else None,
                "status": h.status,
                "created_at": h.created_at.isoformat(),
            }
            for h in pending_hw
        ],
        "completed_homework": [
            {
                "id": h.id,
                "content": h.content,
                "completed_at": h.completed_at.isoformat() if h.completed_at else None,
                "completed_by": h.completed_by,
            }
            for h in completed_hw
        ],
    }


# ── Comments ──────────────────────────────────────────────────────────────────

async def create_comment(
    db: AsyncSession, instructor_id: int, student_id: int, content: str
) -> InstructorComment:
    await _get_instructor(db, instructor_id)
    # verify active connection
    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    if result.scalar_one_or_none() is None:
        raise HTTPException(status_code=403, detail="No active connection with student")

    comment = InstructorComment(
        instructor_id=instructor_id,
        student_id=student_id,
        content=content,
    )
    db.add(comment)
    await db.commit()
    await db.refresh(comment)
    return comment


async def update_comment(
    db: AsyncSession, instructor_id: int, comment_id: int, content: str
) -> InstructorComment:
    comment = await db.get(InstructorComment, comment_id)
    if comment is None or comment.deleted_at is not None:
        raise HTTPException(status_code=404, detail="Comment not found")
    if comment.instructor_id != instructor_id:
        raise HTTPException(status_code=403, detail="Not your comment")

    now = datetime.now(timezone.utc)
    elapsed = (now - comment.created_at.replace(tzinfo=timezone.utc)).total_seconds()
    if elapsed > 600:
        raise HTTPException(status_code=403, detail="Edit window (10 min) expired")

    comment.content = content
    comment.edited_at = now
    await db.commit()
    await db.refresh(comment)
    return comment


async def delete_comment(db: AsyncSession, instructor_id: int, comment_id: int) -> None:
    comment = await db.get(InstructorComment, comment_id)
    if comment is None or comment.deleted_at is not None:
        raise HTTPException(status_code=404, detail="Comment not found")
    if comment.instructor_id != instructor_id:
        raise HTTPException(status_code=403, detail="Not your comment")

    comment.deleted_at = datetime.now(timezone.utc)
    await db.commit()


async def mark_comment_read(db: AsyncSession, student_id: int, comment_id: int) -> None:
    comment = await db.get(InstructorComment, comment_id)
    if comment is None or comment.deleted_at is not None:
        raise HTTPException(status_code=404, detail="Comment not found")
    if comment.student_id != student_id:
        raise HTTPException(status_code=403, detail="Not your comment")

    if not comment.is_read:
        comment.is_read = True
        comment.read_at = datetime.now(timezone.utc)
        await db.commit()


async def list_comments(
    db: AsyncSession, requestor_id: int, student_id: int
) -> list[InstructorComment]:
    requestor = await db.get(User, requestor_id)
    if requestor is None:
        raise HTTPException(status_code=404, detail="User not found")

    if requestor.role == "instructor":
        result = await db.execute(
            select(InstructorComment).where(
                InstructorComment.instructor_id == requestor_id,
                InstructorComment.student_id == student_id,
                InstructorComment.deleted_at.is_(None),
            ).order_by(InstructorComment.created_at.desc())
        )
    else:
        result = await db.execute(
            select(InstructorComment).where(
                InstructorComment.student_id == requestor_id,
                InstructorComment.deleted_at.is_(None),
            ).order_by(InstructorComment.created_at.desc())
        )
    return result.scalars().all()


# ── Homework ──────────────────────────────────────────────────────────────────

async def create_homework(
    db: AsyncSession, instructor_id: int, student_id: int, content: str, due_date: date
) -> Homework:
    await _get_instructor(db, instructor_id)

    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    if result.scalar_one_or_none() is None:
        raise HTTPException(status_code=403, detail="No active connection with student")

    # max 3 pending homework per student
    pending = await db.execute(
        select(Homework).where(
            Homework.student_id == student_id,
            Homework.instructor_id == instructor_id,
            Homework.status == "pending",
        )
    )
    if len(pending.scalars().all()) >= 3:
        raise HTTPException(status_code=400, detail="Student already has 3 pending homework items")

    hw = Homework(
        instructor_id=instructor_id,
        student_id=student_id,
        content=content,
        due_date=due_date,
    )
    db.add(hw)

    # sync to user's homework_text (latest pending)
    student = await db.get(User, student_id)
    if student:
        student.homework_text = content

    await db.commit()
    await db.refresh(hw)
    return hw


async def complete_homework(
    db: AsyncSession, user_id: int, homework_id: int
) -> Homework:
    hw = await db.get(Homework, homework_id)
    if hw is None or hw.status != "pending":
        raise HTTPException(status_code=404, detail="Homework not found or not pending")

    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    is_student = user.role == "student" and hw.student_id == user_id
    is_instructor = user.role == "instructor" and hw.instructor_id == user_id
    if not (is_student or is_instructor):
        raise HTTPException(status_code=403, detail="Not authorized")

    hw.status = "completed"
    hw.completed_at = datetime.now(timezone.utc)
    hw.completed_by = "student" if is_student else "instructor"

    # clear homework_text if no more pending
    student = await db.get(User, hw.student_id)
    if student:
        remaining = await db.execute(
            select(Homework).where(
                Homework.student_id == hw.student_id,
                Homework.instructor_id == hw.instructor_id,
                Homework.status == "pending",
                Homework.id != homework_id,
            )
        )
        items = remaining.scalars().all()
        student.homework_text = items[0].content if items else ""

    await db.commit()
    await db.refresh(hw)
    return hw


async def get_dojo_stats(
    db: AsyncSession,
    instructor_id: int,
    start_date: date,
    end_date: date,
) -> list[dict]:
    await _get_instructor(db, instructor_id)

    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.status == "active",
        )
    )
    members = result.scalars().all()

    stats = []
    for m in members:
        student = await db.get(User, m.student_id)
        if not student:
            continue

        sessions_result = await db.execute(
            select(TrainingSession).where(TrainingSession.user_id == m.student_id)
        )
        all_sessions = sessions_result.scalars().all()
        period_sessions = [s for s in all_sessions if start_date <= s.session_date <= end_date]
        last_date = max((s.session_date for s in all_sessions), default=None)

        hw_result = await db.execute(
            select(Homework).where(
                Homework.student_id == m.student_id,
                Homework.instructor_id == instructor_id,
                Homework.status == "pending",
            )
        )
        pending_hw = hw_result.scalars().all()

        stats.append({
            "student_id": student.id,
            "display_name": student.display_name,
            "belt_level": student.belt_level or "",
            "total_sessions": len(all_sessions),
            "sessions_in_period": len(period_sessions),
            "last_session_date": last_date.isoformat() if last_date else None,
            "pending_homework": len(pending_hw),
        })

    return stats


async def get_homework_stats(db: AsyncSession, instructor_id: int) -> dict:
    await _get_instructor(db, instructor_id)

    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.status == "active",
        )
    )
    members = result.scalars().all()

    pending_details: list[dict] = []
    completed_details: list[dict] = []

    thirty_days_ago = (datetime.now(timezone.utc).date() - timedelta(days=30))

    for m in members:
        student = await db.get(User, m.student_id)
        if not student:
            continue

        pending_result = await db.execute(
            select(Homework).where(
                Homework.student_id == m.student_id,
                Homework.instructor_id == instructor_id,
                Homework.status == "pending",
            )
        )
        pending_items = pending_result.scalars().all()
        if pending_items:
            pending_details.append({
                "student_id": student.id,
                "student_name": student.display_name,
                "items": [
                    {
                        "id": hw.id,
                        "content": hw.content,
                        "due_date": hw.due_date.isoformat() if hw.due_date else None,
                    }
                    for hw in pending_items
                ],
            })

        completed_result = await db.execute(
            select(Homework).where(
                Homework.student_id == m.student_id,
                Homework.instructor_id == instructor_id,
                Homework.status == "completed",
                Homework.completed_at >= datetime(
                    thirty_days_ago.year,
                    thirty_days_ago.month,
                    thirty_days_ago.day,
                    tzinfo=timezone.utc,
                ),
            )
        )
        completed_items = completed_result.scalars().all()
        if completed_items:
            completed_details.append({
                "student_id": student.id,
                "student_name": student.display_name,
                "items": [
                    {
                        "id": hw.id,
                        "content": hw.content,
                        "completed_at": hw.completed_at.isoformat() if hw.completed_at else None,
                    }
                    for hw in completed_items
                ],
            })

    return {
        "pending_total": sum(len(d["items"]) for d in pending_details),
        "completed_total": sum(len(d["items"]) for d in completed_details),
        "pending_details": pending_details,
        "completed_details": completed_details,
    }


async def create_group_homework(
    db: AsyncSession, instructor_id: int, content: str, due_date: date
) -> int:
    await _get_instructor(db, instructor_id)
    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.status == "active",
        )
    )
    members = result.scalars().all()
    if not members:
        raise HTTPException(status_code=400, detail="No active students")

    count = 0
    for member in members:
        pending = await db.execute(
            select(Homework).where(
                Homework.student_id == member.student_id,
                Homework.instructor_id == instructor_id,
                Homework.status == "pending",
            )
        )
        if len(pending.scalars().all()) >= 3:
            continue
        hw = Homework(
            instructor_id=instructor_id,
            student_id=member.student_id,
            content=content,
            due_date=due_date,
        )
        db.add(hw)
        student = await db.get(User, member.student_id)
        if student and not student.homework_text:
            student.homework_text = content
        count += 1

    await db.commit()
    return count


async def get_student_journal(
    db: AsyncSession, instructor_id: int, student_id: int
) -> dict:
    await _get_instructor(db, instructor_id)
    result = await db.execute(
        select(DojoMember).where(
            DojoMember.instructor_id == instructor_id,
            DojoMember.student_id == student_id,
            DojoMember.status == "active",
        )
    )
    if result.scalar_one_or_none() is None:
        raise HTTPException(status_code=403, detail="No active connection with student")

    sessions_result = await db.execute(
        select(TrainingSession)
        .where(TrainingSession.user_id == student_id)
        .order_by(TrainingSession.session_date.desc())
        .limit(10)
    )
    sessions = sessions_result.scalars().all()

    weaknesses_result = await db.execute(
        select(WeaknessPattern)
        .where(WeaknessPattern.user_id == student_id)
        .order_by(WeaknessPattern.consecutive_count.desc())
    )
    weaknesses = weaknesses_result.scalars().all()

    readiness_result = await db.execute(
        select(PromotionReadiness).where(PromotionReadiness.user_id == student_id)
    )
    readiness = readiness_result.scalar_one_or_none()

    return {
        "sessions": [
            {
                "id": s.id,
                "session_date": s.session_date.isoformat(),
                "duration_minutes": s.duration_minutes,
                "training_type": s.training_type,
                "score": s.score,
                "notes": s.notes,
            }
            for s in sessions
        ],
        "weaknesses": [
            {
                "movement_name": w.movement_name,
                "consecutive_count": w.consecutive_count,
            }
            for w in weaknesses
        ],
        "readiness": {
            "sparring_check": readiness.sparring_check if readiness else False,
            "breaking_check": readiness.breaking_check if readiness else False,
            "theory_test_passed": readiness.theory_test_passed if readiness else False,
        },
    }


async def list_pending_homework(
    db: AsyncSession, requestor_id: int, student_id: int
) -> list[Homework]:
    requestor = await db.get(User, requestor_id)
    if requestor is None:
        raise HTTPException(status_code=404, detail="User not found")

    if requestor.role == "instructor":
        target_student_id = student_id
    else:
        target_student_id = requestor_id

    result = await db.execute(
        select(Homework).where(
            Homework.student_id == target_student_id,
            Homework.status == "pending",
        ).order_by(Homework.due_date)
    )
    return result.scalars().all()
