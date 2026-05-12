import os

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...core.deps import get_current_user
from ...core.security import hash_password, verify_password
from ...models.user import User
from ...schemas.user import ChangePasswordRequest, UpdateUserRequest, UserResponse

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.put("/me", response_model=UserResponse)
async def update_me(
    req: UpdateUserRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if req.display_name is not None:
        current_user.display_name = req.display_name
    if req.belt_level is not None:
        current_user.belt_level = req.belt_level
    if req.language_code is not None:
        current_user.language_code = req.language_code
    if req.ai_provider is not None:
        current_user.ai_provider = req.ai_provider

    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.post("/me/avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    content = await file.read()
    static_dir = os.path.join(
        os.path.dirname(__file__), "..", "..", "..", "static", "avatars"
    )
    os.makedirs(static_dir, exist_ok=True)
    filename = f"{current_user.id}.jpg"
    with open(os.path.join(static_dir, filename), "wb") as f:
        f.write(content)
    current_user.avatar_url = f"/static/avatars/{filename}"
    await db.commit()
    return {"avatar_url": current_user.avatar_url}


@router.put("/me/password", status_code=204)
async def change_password(
    req: ChangePasswordRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if not verify_password(req.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect",
        )
    current_user.hashed_password = hash_password(req.new_password)
    await db.commit()
