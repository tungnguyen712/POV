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


def get_scans_for_user(user_id: str, limit: int = 50) -> list[dict[str, Any]]:
    """Fetch newest scans for a user (for Wrapped/Journey)."""
    try:
        supabase = get_supabase()
        res = (
            supabase.table("scans")
            .select("id,user_id,landmark_name,description,lat,lng,tags,timestamp")
            .eq("user_id", user_id)
            .order("timestamp", desc=True)
            .limit(limit)
            .execute()
        )

        if res.data and isinstance(res.data, list):
            return [x for x in res.data if isinstance(x, dict)]
    except Exception as e:
        print(f"ERROR getting scans: {e}")
    return []


def get_profile(user_id: str) -> Optional[dict[str, Any]]:
    """Get user profile from the database"""
    # TODO: Replace with real database query once user DB is ready
    mock_profiles = {
        "test-user-123": {
            "user_id": "test-user-123",
            "age_bracket": "adult",
            "interests": ["history", "architecture", "art", "culture"]
        },
        "kid-user": {
            "user_id": "kid-user",
            "age_bracket": "kid",
            "interests": ["animals", "nature", "science"]
        }
    }

    return mock_profiles.get(user_id)
