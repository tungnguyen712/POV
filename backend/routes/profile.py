from fastapi import APIRouter, HTTPException
from schemas.profile import ProfileResponse, UserProfile, UserStats
from db import queries

router = APIRouter(prefix="/profile", tags=["Profile"])

@router.get("/{user_id}", response_model=ProfileResponse)
async def get_user_profile(user_id: str):
    """Get user profile and statistics"""
    try:
        # Get profile data
        profile_data = queries.get_profile(user_id)
        
        if not profile_data:
            raise HTTPException(status_code=404, detail="Profile not found")
        
        # Get user stats
        stats_data = queries.get_user_stats(user_id)
        
        return ProfileResponse(
            profile=UserProfile(
                user_id=profile_data["user_id"],
                username=profile_data.get("username"),
                email=profile_data.get("email"),
                age_bracket=profile_data.get("age_bracket"),
                interests=profile_data.get("interests", []),
            ),
            stats=UserStats(
                places_visited=stats_data["places_visited"],
                scans_this_week=stats_data["scans_this_week"],
                streak_days=stats_data["streak_days"],
            )
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching profile: {str(e)}")
