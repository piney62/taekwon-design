"""
ITF Coach 테스트 데이터 시드 스크립트
실행: python seed.py [--username USERNAME] [--mode self|dojo]
기본값: --username demo --mode dojo
"""
import argparse
import asyncio
import os
import sys
from datetime import date, datetime, timedelta, timezone

# Windows asyncio & encoding
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    sys.stdout.reconfigure(encoding="utf-8")
    sys.stderr.reconfigure(encoding="utf-8")

# bcrypt 오류 방지
os.environ.setdefault("SSLKEYLOGFILE", "")

from sqlalchemy import delete, select

from app.core.database import AsyncSessionLocal, Base, engine
from app.core.security import hash_password
from app.models.journal import PromotionReadiness, TrainingSession, WeaknessPattern
from app.models.user import User


TODAY = date(2026, 5, 5)


def _dt(d: date) -> datetime:
    return datetime(d.year, d.month, d.day, 10, 0, 0, tzinfo=timezone.utc)


def _make_sessions(user_id: int) -> list[dict]:
    sessions = []

    # 최근 12일 연속 훈련 (2026-04-24 ~ 2026-05-05)
    recent_data = [
        # (date_offset, is_auto_saved, type, duration, score, notes, instructor_comment)
        (0,  True,  "pattern", 60, 3, "전지 분석·지적 3개", "많이 좋아졌어요!"),
        (1,  True,  "pattern", 45, 3, "전지 분석·지적 4개", ""),
        (2,  False, "other",   30, 4, "기본 동작 연습 - 발차기 반복", ""),
        (3,  True,  "pattern", 50, 4, "전지 분석·지적 2개", ""),
        (4,  True,  "pattern", 50, 3, "전지 분석·지적 5개", ""),
        (5,  True,  "pattern", 55, 3, "전지 분석·지적 4개", ""),
        (6,  True,  "pattern", 45, 4, "전지 분석·지적 3개", ""),
        (7,  True,  "pattern", 50, 3, "전지 분석·지적 4개", ""),
        (8,  True,  "pattern", 45, 4, "전지 분석·지적 3개", ""),
        (9,  True,  "pattern", 60, 4, "전지 분석·지적 2개", ""),
        (10, True,  "pattern", 50, 4, "전지 분석·지적 3개", ""),
        (11, True,  "pattern", 45, 3, "전지 분석·지적 4개", ""),
    ]
    for offset, auto, t, dur, sc, notes, comment in recent_data:
        d = TODAY - timedelta(days=offset)
        sessions.append({
            "user_id": user_id,
            "session_date": d,
            "duration_minutes": dur,
            "training_type": t,
            "score": sc,
            "notes": notes,
            "is_auto_saved": auto,
            "instructor_comment": comment,
            "created_at": _dt(d),
        })

    # 이전 기록: 2026-01-10 ~ 2026-04-22 (3일 간격으로 auto-saved)
    # 12 + 35 = 47 auto-saved 목표
    d = TODAY - timedelta(days=13)  # 2026-04-22
    older_auto = 0
    target = 35  # 추가로 필요한 auto-saved 수
    while older_auto < target and d >= date(2026, 1, 10):
        sessions.append({
            "user_id": user_id,
            "session_date": d,
            "duration_minutes": 45 + (older_auto % 3) * 5,
            "training_type": "pattern",
            "score": 3 + (older_auto % 3),
            "notes": f"전지 분석·지적 {3 + older_auto % 4}개",
            "is_auto_saved": True,
            "instructor_comment": "",
            "created_at": _dt(d),
        })
        older_auto += 1
        d -= timedelta(days=3)

    return sessions


async def _migrate(conn) -> None:
    """기존 테이블에 새 컬럼 추가 (없으면 무시)."""
    from sqlalchemy import text
    migrations = [
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS dojo_connected BOOLEAN DEFAULT FALSE",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS instructor_name VARCHAR(100) DEFAULT ''",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS homework_text TEXT DEFAULT ''",
        "ALTER TABLE training_sessions ADD COLUMN IF NOT EXISTS is_auto_saved BOOLEAN DEFAULT FALSE",
        "ALTER TABLE training_sessions ADD COLUMN IF NOT EXISTS instructor_comment TEXT DEFAULT ''",
    ]
    for sql in migrations:
        await conn.execute(text(sql))
    print("마이그레이션 완료")


async def seed(username: str, mode: str) -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        await _migrate(conn)

    async with AsyncSessionLocal() as db:
        # 유저 찾기 또는 생성
        result = await db.execute(select(User).where(User.username == username))
        user = result.scalar_one_or_none()

        dojo = mode == "dojo"

        if user is None:
            print(f"유저 '{username}' 없음 → 새로 생성")
            user = User(
                username=username,
                display_name="홍길동",
                hashed_password=hash_password("1234"),
                belt_level="yellow",
                language_code="ko",
                ai_provider="groq",
                dojo_connected=dojo,
                instructor_name="강현수" if dojo else "",
                homework_text="전지 5동작 집중 연습 — 이번주 내" if dojo else "",
                created_at=datetime(2026, 1, 5, tzinfo=timezone.utc),
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
        else:
            print(f"유저 '{username}' 발견 → 도장 설정 업데이트")
            user.dojo_connected = dojo
            user.instructor_name = "강현수" if dojo else ""
            user.homework_text = "전지 5동작 집중 연습 — 이번주 내" if dojo else ""
            # created_at을 4개월 전으로 (이미 오래된 유저가 아닐 경우만)
            if user.created_at.date() > date(2026, 1, 10):
                user.created_at = datetime(2026, 1, 5, tzinfo=timezone.utc)
            await db.commit()

        uid = user.id

        # 기존 테스트 데이터 삭제
        await db.execute(delete(TrainingSession).where(TrainingSession.user_id == uid))
        await db.execute(delete(WeaknessPattern).where(WeaknessPattern.user_id == uid))
        await db.execute(delete(PromotionReadiness).where(PromotionReadiness.user_id == uid))
        await db.commit()

        # 훈련 세션 삽입
        sessions = _make_sessions(uid)
        for s in sessions:
            db.add(TrainingSession(**s))
        await db.commit()
        auto_count = sum(1 for s in sessions if s["is_auto_saved"])
        print(f"훈련 기록 {len(sessions)}개 삽입 (자동저장 {auto_count}개)")

        # 약점 패턴 삽입
        weaknesses = [
            WeaknessPattern(
                user_id=uid,
                movement_name="3동작 앞굽이 무릎",
                consecutive_count=5,
                detected_at=_dt(TODAY - timedelta(days=1)),
            ),
            WeaknessPattern(
                user_id=uid,
                movement_name="7동작 중단막기",
                consecutive_count=3,
                detected_at=_dt(TODAY - timedelta(days=2)),
            ),
            WeaknessPattern(
                user_id=uid,
                movement_name="9동작 앞차기 높이",
                consecutive_count=2,
                detected_at=_dt(TODAY - timedelta(days=3)),
            ),
        ]
        for w in weaknesses:
            db.add(w)
        await db.commit()
        print(f"약점 패턴 {len(weaknesses)}개 삽입")

        # 준비도 삽입
        readiness = PromotionReadiness(
            user_id=uid,
            sparring_check=False,
            breaking_check=False,
            theory_test_passed=False,
        )
        db.add(readiness)
        await db.commit()
        print("준비도 레코드 삽입")

        print(f"\n완료! 유저: {username} / 비밀번호: 1234 / 모드: {'도장' if dojo else '자습'}")
        print(f"서버 실행 후 로그인하면 데모 데이터를 확인할 수 있습니다.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--username", default="demo")
    parser.add_argument("--mode", choices=["self", "dojo"], default="dojo")
    args = parser.parse_args()
    asyncio.run(seed(args.username, args.mode))
