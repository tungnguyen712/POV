from pydantic import BaseModel
from typing import Optional, List

class UserProfile(BaseModel):
    user_id: str
    username: Optional[str] = None
    email: Optional[str] = None
    age_bracket: Optional[str] = None
    interests: List[str] = []

class UserStats(BaseModel):
    places_visited: int
    scans_this_week: int
    streak_days: int

class ProfileResponse(BaseModel):
    profile: UserProfile
    stats: UserStats
