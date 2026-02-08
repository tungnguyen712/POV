from pydantic import BaseModel
from typing import Optional, List


class ScanItem(BaseModel):
    id: str
    user_id: str
    landmark_name: str
    description: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    tags: List[str] = []
    timestamp: Optional[str] = None
