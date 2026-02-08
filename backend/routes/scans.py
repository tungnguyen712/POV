from fastapi import APIRouter, Query
from typing import List
from db.queries import get_scans_for_user
from schemas.scans import ScanItem

router = APIRouter(prefix="/scans", tags=["Scans"])

@router.get("/{user_id}", response_model=List[ScanItem])
def get_scans(user_id: str, limit: int = Query(200, ge=1, le=500)):
    scans = get_scans_for_user(user_id=user_id, limit=limit)
    return scans
