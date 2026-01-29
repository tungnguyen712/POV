from typing import Optional, Any
from datetime import datetime
from db.supabase import get_supabase

def save_scan(
    user_id: str,
    landmark_name: str,
    description: str,
    lat: Optional[float],
    lng: Optional[float],
    tags: list[str],
    timestamp: datetime,
) -> Optional[dict[str, Any]]:
    """Save a landmark scan to the database"""
    try:
        supabase = get_supabase()
        
        data = {
            "user_id": user_id,
            "landmark_name": landmark_name,
            "description": description,
            "lat": lat,
            "lng": lng,
            "tags": tags,
            "timestamp": timestamp.isoformat(),
        }
        
        result = supabase.table("scans").insert(data).execute()
        if result.data and isinstance(result.data, list) and len(result.data) > 0:
            item = result.data[0]
            if isinstance(item, dict):
                return item
    except Exception as e:
        print(f"ERROR saving scan: {e}")
    return None


def get_profile(user_id: str) -> Optional[dict[str, Any]]:
    """Get user profile from the database"""
    # TODO: Replace with real database query once user DB is ready
    mock_profiles = {
        "test-user-123": {
            "user_id": "test-user-123",
            "age_bracket": "adult",
            "interests": ["history", "architecture", "art", "culture"]
        },
        "child-user": {
            "user_id": "child-user",
            "age_bracket": "child",
            "interests": ["animals", "nature", "science"]
        }
    }
    
    return mock_profiles.get(user_id)
    
    # get real profile from DB
    # supabase = get_supabase()
    # result = supabase.table("profiles").select("*").eq("user_id", user_id).execute()
    # if result.data and isinstance(result.data, list) and len(result.data) > 0:
    #     item = result.data[0]
    #     if isinstance(item, dict):
    #         return item
    # return None
