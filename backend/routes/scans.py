from fastapi import APIRouter, Query
from backend.db import queries

router = APIRouter(prefix="/scans", tags=["Scans"])


@router.get("/{user_id}")
def get_scans(user_id: str, limit: int = Query(200, ge=1, le=500)):
    return queries.get_scans_for_user(user_id=user_id, limit=limit)
