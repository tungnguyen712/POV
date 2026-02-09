from backend.db.queries import get_scans_for_user, get_top_city_for_user
from backend.schemas.wrapped import WrappedResponse, WrappedScanItem


def _norm_landmark(name: str | None) -> str:
    """Normalize landmark name for uniqueness counting."""
    if not name:
        return ""
    t = name.strip().lower()
    if t in {"unknown", "uncertain"}:
        return ""
    return t


def build_wrapped(user_id: str, limit: int = 50) -> WrappedResponse:
    scans = get_scans_for_user(user_id=user_id, limit=limit)

    items: list[WrappedScanItem] = []
    unique = set()

    for s in scans:
        name = s.get("landmark_name")
        key = _norm_landmark(name)
        if key:
            unique.add(key)

        items.append(
            WrappedScanItem(
                landmark_name=name or "Unknown",
                tags=s.get("tags") if isinstance(s.get("tags"), list) else [],
                timestamp=s.get("timestamp"),
            )
        )


    top_city = get_top_city_for_user(user_id)

    return WrappedResponse(
        total_scans=len(scans),
        unique_landmarks=len(unique),
        top_city=top_city,          
        items=items,
    )
