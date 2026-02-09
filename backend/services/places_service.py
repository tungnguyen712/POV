import os
import math
from typing import Iterable

import httpx

from backend.schemas.identify import PlaceSuggestion
from backend.services.cache import get as cache_get, set as cache_set

PLACES_BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"


def _haversine_meters(lat1: float, lng1: float, lat2: float, lng2: float) -> int:
    # Returns distance in meters between two lat/lng points.
    r = 6371000.0
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lng2 - lng1)
    a = math.sin(dphi / 2.0) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2.0) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return int(r * c)


def _score_place(place: PlaceSuggestion, radius_m: int) -> float:
    if place.distance_meters is None:
        return 0.0
    dist_score = max(0.0, 1.0 - (place.distance_meters / max(1, radius_m)))
    rating_score = (place.rating or 0.0) / 5.0
    open_bonus = 0.15 if place.open_now else 0.0
    return (0.55 * dist_score) + (0.35 * rating_score) + open_bonus


def _dedupe_places(items: Iterable[PlaceSuggestion]) -> list[PlaceSuggestion]:
    seen: set[str] = set()
    result: list[PlaceSuggestion] = []
    for item in items:
        key = item.place_id or f"{item.name}:{item.address}"
        if key in seen:
            continue
        seen.add(key)
        result.append(item)
    return result


async def _fetch_places(
    lat: float,
    lng: float,
    place_type: str,
    radius_m: int,
    max_results: int,
) -> list[PlaceSuggestion]:
    api_key = os.getenv("GOOGLE_PLACES_API_KEY")
    if not api_key:
        return []

    cache_key = f"places:{place_type}:{round(lat,4)}:{round(lng,4)}:{radius_m}"
    cached = cache_get(cache_key)
    if cached:
        return cached

    params = {
        "key": api_key,
        "location": f"{lat},{lng}",
        "radius": radius_m,
        "type": place_type,
    }

    async with httpx.AsyncClient(timeout=8.0) as client:
        resp = await client.get(PLACES_BASE_URL, params=params)
        resp.raise_for_status()
        data = resp.json()

    results = data.get("results", [])
    places: list[PlaceSuggestion] = []
    for item in results:
        geometry = item.get("geometry", {}).get("location", {})
        place_lat = geometry.get("lat")
        place_lng = geometry.get("lng")
        if place_lat is None or place_lng is None:
            distance_meters = None
        else:
            distance_meters = _haversine_meters(lat, lng, place_lat, place_lng)

        place_id = item.get("place_id")
        places.append(
            PlaceSuggestion(
                name=item.get("name", "Unknown"),
                lat=place_lat,
                lng=place_lng,
                address=item.get("vicinity") or item.get("formatted_address"),
                rating=item.get("rating"),
                user_ratings_total=item.get("user_ratings_total"),
                distance_meters=distance_meters,
                open_now=(item.get("opening_hours", {}) or {}).get("open_now"),
                place_id=place_id,
                types=item.get("types") or [],
                maps_url=f"https://www.google.com/maps/place/?q=place_id:{place_id}" if place_id else None,
            )
        )

    places = sorted(places, key=lambda p: _score_place(p, radius_m), reverse=True)[:max_results]
    cache_set(cache_key, places, ttl_seconds=60 * 10)
    return places


async def get_nearby_landmarks(
    lat: float,
    lng: float,
    radius_m: int = 1500,
    max_results: int = 6,
) -> list[PlaceSuggestion]:
    place_types = ["tourist_attraction", "museum", "park"]
    collected: list[PlaceSuggestion] = []
    for place_type in place_types:
        collected.extend(await _fetch_places(lat, lng, place_type, radius_m, max_results))
    deduped = _dedupe_places(collected)
    ranked = sorted(deduped, key=lambda p: _score_place(p, radius_m), reverse=True)
    return ranked[:max_results]


async def get_nearby_food(
    lat: float,
    lng: float,
    radius_m: int = 1500,
    max_results: int = 6,
) -> list[PlaceSuggestion]:
    place_types = ["restaurant", "cafe", "bakery"]
    collected: list[PlaceSuggestion] = []
    for place_type in place_types:
        collected.extend(await _fetch_places(lat, lng, place_type, radius_m, max_results))
    deduped = _dedupe_places(collected)
    ranked = sorted(deduped, key=lambda p: _score_place(p, radius_m), reverse=True)
    return ranked[:max_results]
