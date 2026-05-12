from pydantic import BaseModel


class PatternVersionsResponse(BaseModel):
    versions: dict[str, int]  # slug → version


class PatternVersionUpdate(BaseModel):
    slug: str
