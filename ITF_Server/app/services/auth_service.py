from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from ..models.user import User
from ..schemas.auth import LoginRequest, RegisterRequest, TokenResponse
from .user_service import get_user_by_email, get_user_by_id, get_user_by_username


async def register(db: AsyncSession, req: RegisterRequest) -> TokenResponse:
    existing = await get_user_by_username(db, req.username)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Username already taken",
        )
    if req.email:
        existing_email = await get_user_by_email(db, req.email)
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

    role = req.role if req.role in ("student", "instructor") else "student"
    _valid_belts = {"white", "yellow", "green", "blue", "red", "black"}
    if role == "instructor":
        belt = "black"
    elif req.belt_level and req.belt_level in _valid_belts:
        belt = req.belt_level
    else:
        belt = "white"
    user = User(
        username=req.username,
        email=req.email or None,
        display_name=req.display_name,
        hashed_password=hash_password(req.password),
        role=role,
        belt_level=belt,
        training_start_year=req.training_start_year if role == "student" else None,
        dojo_name=req.dojo_name if role == "instructor" else None,
        dan_rank=req.dan_rank if role == "instructor" else None,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    return TokenResponse(
        access_token=create_access_token(str(user.id)),
        refresh_token=create_refresh_token(str(user.id)),
    )


async def login(db: AsyncSession, req: LoginRequest) -> TokenResponse:
    user = await get_user_by_username(db, req.username)
    if user is None or not verify_password(req.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
        )

    return TokenResponse(
        access_token=create_access_token(str(user.id)),
        refresh_token=create_refresh_token(str(user.id)),
    )


async def refresh(db: AsyncSession, refresh_token: str) -> TokenResponse:
    try:
        user_id = decode_token(refresh_token, token_type="refresh")
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    user = await get_user_by_id(db, int(user_id))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
        )

    return TokenResponse(
        access_token=create_access_token(str(user.id)),
        refresh_token=create_refresh_token(str(user.id)),
    )
