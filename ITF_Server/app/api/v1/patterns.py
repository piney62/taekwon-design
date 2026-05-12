from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...core.database import get_db
from ...models.pattern import PatternImageVersion
from ...schemas.pattern import PatternVersionsResponse

router = APIRouter(prefix="/patterns", tags=["patterns"])

_ALL_SLUGS = [
    "chon_ji", "dan_gun", "do_san", "won_hyo", "yul_gok",
    "joong_gun", "toi_gye", "hwa_rang", "choong_moo", "kwang_gae",
    "po_eun", "ge_baek", "eui_am", "choong_jang", "juche",
    "sam_il", "yoo_sin", "choi_yong", "yon_gae", "ul_ji",
    "moon_moo", "so_san", "se_jong", "tong_il",
]

# 현재 지원 파: vienna 기본, 추후 pyongyang / canada 추가 가능
_SUPPORTED_FACTIONS = {"vienna", "pyongyang", "canada"}


async def _ensure_versions(db: AsyncSession, faction: str) -> dict[str, int]:
    result = await db.execute(
        select(PatternImageVersion).where(PatternImageVersion.faction == faction)
    )
    existing = {row.slug: row for row in result.scalars().all()}

    for slug in _ALL_SLUGS:
        if slug not in existing:
            db.add(PatternImageVersion(faction=faction, slug=slug, version=1))

    await db.commit()

    result = await db.execute(
        select(PatternImageVersion).where(PatternImageVersion.faction == faction)
    )
    return {row.slug: row.version for row in result.scalars().all()}


@router.get("/versions", response_model=PatternVersionsResponse)
async def get_pattern_versions(
    faction: str = Query(default="vienna", description="ITF 파: vienna | pyongyang | canada"),
    db: AsyncSession = Depends(get_db),
):
    versions = await _ensure_versions(db, faction)
    return PatternVersionsResponse(versions=versions)


@router.get("/factions")
async def get_supported_factions():
    """지원하는 ITF 파 목록"""
    return {
        "factions": [
            {"id": "vienna",    "name": "ITF-Vienna",    "active": True},
            {"id": "pyongyang", "name": "ITF-Pyongyang", "active": False},
            {"id": "canada",    "name": "ITF-Canada",    "active": False},
        ]
    }


@router.post("/versions/{slug}/bump")
async def bump_pattern_version(
    slug: str,
    faction: str = Query(default="vienna"),
    db: AsyncSession = Depends(get_db),
):
    """이미지 교체 후 버전 증가 → 해당 파의 모든 클라이언트 캐시 무효화"""
    result = await db.execute(
        select(PatternImageVersion).where(
            PatternImageVersion.faction == faction,
            PatternImageVersion.slug == slug,
        )
    )
    row = result.scalar_one_or_none()
    if row is None:
        row = PatternImageVersion(faction=faction, slug=slug, version=1)
        db.add(row)
    else:
        row.version += 1
    await db.commit()
    return {"faction": faction, "slug": slug, "version": row.version}
