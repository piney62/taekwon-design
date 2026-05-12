import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import text

from .api.v1.router import api_router
from .core.config import settings
from .core.database import engine, Base
from .models import User, TrainingSession, WeaknessPattern, PromotionReadiness, InviteCode, DojoMember, InstructorComment, Homework, PatternImageVersion, PoseAnalysisRecord  # noqa: F401


async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        await conn.execute(text(
            "ALTER TABLE training_sessions "
            "ADD COLUMN IF NOT EXISTS selected_movements TEXT DEFAULT ''"
        ))
        await conn.execute(text(
            "ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url VARCHAR(500)"
        ))
    yield


app = FastAPI(
    title="ITF Coach API",
    version="1.0.0",
    description="Backend API for ITF Taekwondo AI Coach application",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)

_static_dir = os.path.join(os.path.dirname(__file__), "..", "static")
os.makedirs(_static_dir, exist_ok=True)
app.mount("/static", StaticFiles(directory=_static_dir), name="static")


@app.get("/health")
async def health():
    return {"status": "ok"}
