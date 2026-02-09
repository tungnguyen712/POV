from typing import Optional, Any
from datetime import datetime
from backend.db.supabase import get_supabase
import uuid


def upload_scan_image(user_id: str, image_bytes: bytes, mime_type: str = "image/jpeg") -> Optional[str]:
    """Upload image to Supabase Storage and return public URL"""
    try:
        supabase = get_supabase()
        
        # Generate unique filename
        extension = mime_type.split("/")[-1]
        filename = f"{user_id}/{uuid.uuid4()}.{extension}"
        
        # Upload to storage
        supabase.storage.from_("scan-images").upload(
            filename,
            image_bytes,
            {"content-type": mime_type}
        )
        
        # Get public URL
        public_url = supabase.storage.from_("scan-images").get_public_url(filename)
        return public_url
    except Exception as e:
        print(f"ERROR uploading image: {e}")
        return None


def update_scan_image_url(scan_id: str, image_url: str) -> bool:
    """Update existing scan with image URL"""
    try:
        supabase = get_supabase()
        result = supabase.table("scans").update({"image_url": image_url}).eq("id", scan_id).execute()
        return bool(result.data)
    except Exception as e:
        print(f"ERROR updating scan image URL: {e}")
        return False

def save_scan(
    user_id: str,
    landmark_name: str,
    description: str,
    lat: Optional[float],
    lng: Optional[float],
    tags: list[str],
    timestamp: datetime,
    image_url: Optional[str] = None,
    city: Optional[str] = None,
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
            "image_url": image_url,
            "city": city, 
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
            .select("id,user_id,landmark_name,description,lat,lng,tags,timestamp,image_url")
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


def get_user_stats(user_id: str) -> dict[str, Any]:
    """Get user statistics from scans table"""
    try:
        supabase = get_supabase()
        
        # Get total places visited (distinct landmarks)
        all_scans = (
            supabase.table("scans")
            .select("landmark_name, timestamp")
            .eq("user_id", user_id)
            .execute()
        )
        
        scans_data = all_scans.data if all_scans.data else []
        
        # Ensure we have a list of dicts
        if not isinstance(scans_data, list):
            scans_data = []
        
        # Count unique landmarks
        unique_landmarks = set()
        for scan in scans_data:
            if isinstance(scan, dict) and scan.get("landmark_name"):
                unique_landmarks.add(scan["landmark_name"])
        places_visited = len(unique_landmarks)
        
        # Count scans this week
        from datetime import datetime, timedelta, timezone
        week_ago = datetime.now(timezone.utc) - timedelta(days=7)
        scans_this_week = 0
        
        for scan in scans_data:
            if isinstance(scan, dict) and scan.get("timestamp"):
                try:
                    timestamp_str = str(scan["timestamp"])
                    scan_time = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
                    if scan_time > week_ago:
                        scans_this_week += 1
                except (ValueError, KeyError):
                    continue
        
        # Calculate streak: once every 3 days counts as 1 streak point
        streak_days = 0
        if scans_data:
            # Extract all scan dates
            scan_dates = set()
            for scan in scans_data:
                if isinstance(scan, dict) and scan.get("timestamp"):
                    try:
                        timestamp_str = str(scan["timestamp"])
                        scan_time = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
                        scan_dates.add(scan_time.date())
                    except (ValueError, KeyError):
                        continue
            
            if scan_dates:
                # Start from today and go backwards in 3-day periods
                today = datetime.now(timezone.utc).date()
                current_date = today
                
                # Check each 3-day period going backwards
                while True:
                    period_start = current_date - timedelta(days=2)
                    period_end = current_date
                    
                    # Check if there's at least one scan in this 3-day period
                    has_scan_in_period = any(
                        period_start <= scan_date <= period_end 
                        for scan_date in scan_dates
                    )
                    
                    if has_scan_in_period:
                        streak_days += 1
                        # Move to next 3-day period backwards
                        current_date = period_start - timedelta(days=1)
                    else:
                        # Streak is broken
                        break
                    
                    # Stop if we've gone too far back (e.g., 1 year)
                    if (today - current_date).days > 365:
                        break
        
        return {
            "places_visited": places_visited,
            "scans_this_week": scans_this_week,
            "streak_days": streak_days,
        }
    except Exception as e:
        print(f"ERROR getting user stats: {e}")
        return {
            "places_visited": 0,
            "scans_this_week": 0,
            "streak_days": 0,
        }


def get_profile(user_id: str) -> Optional[dict[str, Any]]:
    """Get user profile from the database"""
    try:    
        supabase = get_supabase()
        result = (
            supabase.table("profiles")
            .select("id, username, email, age_group, interest, onboarding_done")
            .eq("id", user_id)
            .maybe_single()
            .execute()
        )
        
        if result and result.data and isinstance(result.data, dict):
            profile = result.data
            
            # Map database columns to expected format
            interest_str = profile.get("interest")
            interests_list = []
            if interest_str and isinstance(interest_str, str):
                interests_list = [i.strip() for i in interest_str.split(",") if i.strip()]
            
            mapped_profile = {
                "user_id": profile.get("id"),
                "age_bracket": profile.get("age_group"),
                "interests": interests_list,
                "username": profile.get("username"),
                "email": profile.get("email"),
            }
            return mapped_profile
        else:
            print(f"[get_profile] No valid profile data found. Result exists: {result is not None}, Has data: {result.data if result else 'N/A'}")
    except Exception as e:
        print(f"ERROR getting profile: {e}")
    return None

def get_top_city_for_user(user_id: str) -> Optional[str]:
    try:
        supabase = get_supabase()
        res = (
            supabase.table("scans")
            .select("city")
            .eq("user_id", user_id)
            .not_.is_("city", "null")
            .execute()
        )

        rows = res.data if isinstance(res.data, list) else []
        cities = [r["city"] for r in rows if r.get("city")]
        if not cities:
            return None

        from collections import Counter
        return Counter(cities).most_common(1)[0][0]
    except Exception as e:
        print(f"ERROR get_top_city_for_user: {e}")
        return None
