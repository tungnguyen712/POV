from fastapi import APIRouter, HTTPException
from backend.db import queries

router = APIRouter(prefix="/wrapped", tags=["Wrapped"])

@router.get("/{user_id}")
async def get_wrapped(user_id: str, limit: int = 50):
    try:
        scans = queries.get_scans_for_user(user_id, limit=limit)

        recent_scans = [
            {
                "id": s.get("id"),
                "landmark_name": s.get("landmark_name"),
                "timestamp": s.get("timestamp"),
                "image_url": s.get("image_url"),
                "category": ", ".join(s.get("tags", [])) if isinstance(s.get("tags"), list) else (s.get("tags") or ""),
            }
            for s in scans
        ]

        # tạm fake cities bằng tag đầu tiên (vì table chưa có city)
        buckets = {}
        for s in scans:
            tags = s.get("tags")
            key = tags[0] if isinstance(tags, list) and tags else "Landmarks"
            buckets[str(key)] = buckets.get(str(key), 0) + 1

        top = sorted(buckets.items(), key=lambda x: x[1], reverse=True)[:6]
        palette = ["#7ADBCF", "#F05B55", "#1F8A70", "#B8F3EA", "#F4B7B2", "#A7F3D0"]

        cities = [
            {"name": name, "color_hex": palette[i % len(palette)], "count": cnt}
            for i, (name, cnt) in enumerate(top)
        ]

        return {"cities": cities, "recent_scans": recent_scans}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
