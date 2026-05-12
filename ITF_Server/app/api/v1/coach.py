import math
from datetime import date, datetime
from typing import Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...core.deps import get_current_user
from ...models.pose_record import PoseAnalysisRecord
from ...models.user import User
from ...schemas.coach import ChatRequest, ChatResponse
from ...schemas.pose import PoseAnalysisResponse, PoseRecordResponse, PoseRecordSave, PoseRecordsPage
from ...services import coach_service, journal_service, pose_service
from ...services.tul_db import TUL_DB

router = APIRouter(prefix="/coach", tags=["coach"])


@router.post("/chat", response_model=ChatResponse)
async def chat(
    req: ChatRequest,
    current_user: User = Depends(get_current_user),
):
    try:
        return await coach_service.chat(current_user, req.messages)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"AI service error: {e}",
        )


@router.post("/analyze-pose", response_model=PoseAnalysisResponse)
async def analyze_pose(
    student_image: UploadFile = File(...),
    tul_name: str = Form(...),
    movement_no: int = Form(...),
    language: str = Form(default="ko"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    student_bytes = await student_image.read()

    try:
        result = await pose_service.analyze_pose(student_bytes, tul_name, movement_no, language)
        result["tul_list"] = list(TUL_DB.keys())
        return PoseAnalysisResponse(**result)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=f"분석 오류: {e}")


@router.post("/pose-records", status_code=201)
async def save_pose_record(
    data: PoseRecordSave,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    tul_info = TUL_DB.get(data.tul_name, {})
    record = PoseAnalysisRecord(
        user_id=current_user.id,
        tul_name=data.tul_name,
        tul_display_name=tul_info.get("name", data.tul_name),
        movement_no=data.movement_no,
        movement_name=data.movement_name,
        score=data.score,
        feedback=data.feedback,
    )
    db.add(record)
    await db.commit()
    await journal_service.record_pose_weakness(
        db, current_user.id, data.movement_name, data.score
    )
    return {"ok": True}


@router.delete("/pose-records/{record_id}", status_code=204)
async def delete_pose_record(
    record_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(PoseAnalysisRecord).where(
            PoseAnalysisRecord.id == record_id,
            PoseAnalysisRecord.user_id == current_user.id,
        )
    )
    record = result.scalar_one_or_none()
    if record is None:
        raise HTTPException(status_code=404, detail="Record not found.")
    await db.delete(record)
    await db.commit()


@router.get("/pose-records", response_model=PoseRecordsPage)
async def list_pose_records(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    tul_name: Optional[str] = Query(None),
    movement_no: Optional[int] = Query(None),
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    search: Optional[str] = Query(None, max_length=100),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
):
    base = (
        select(PoseAnalysisRecord)
        .where(PoseAnalysisRecord.user_id == current_user.id)
    )

    if tul_name:
        base = base.where(PoseAnalysisRecord.tul_name == tul_name)
    if movement_no is not None:
        base = base.where(PoseAnalysisRecord.movement_no == movement_no)
    if start_date:
        base = base.where(
            PoseAnalysisRecord.created_at >= datetime(start_date.year, start_date.month, start_date.day)
        )
    if end_date:
        base = base.where(
            PoseAnalysisRecord.created_at <= datetime(end_date.year, end_date.month, end_date.day, 23, 59, 59)
        )
    if search:
        keyword = f"%{search}%"
        base = base.where(
            PoseAnalysisRecord.tul_display_name.ilike(keyword)
            | PoseAnalysisRecord.movement_name.ilike(keyword)
        )

    count_result = await db.execute(select(func.count()).select_from(base.subquery()))
    total = count_result.scalar_one()

    records_result = await db.execute(
        base.order_by(PoseAnalysisRecord.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    records = records_result.scalars().all()

    return PoseRecordsPage(
        records=records,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=max(1, math.ceil(total / page_size)),
    )


@router.get("/tul-list")
async def get_tul_list(current_user: User = Depends(get_current_user)):
    result = []
    for tul_id, tul in TUL_DB.items():
        result.append({
            "id": tul_id,
            "name": tul["name"],
            "movements": [{"no": m["no"], "name": m["name"]} for m in tul["movements"]],
        })
    return result
