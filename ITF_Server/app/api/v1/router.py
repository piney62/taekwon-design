from fastapi import APIRouter

from .auth import router as auth_router
from .coach import router as coach_router
from .dojo import router as dojo_router
from .journal import router as journal_router
from .patterns import router as patterns_router
from .users import router as users_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(journal_router)
api_router.include_router(coach_router)
api_router.include_router(dojo_router)
api_router.include_router(patterns_router)
