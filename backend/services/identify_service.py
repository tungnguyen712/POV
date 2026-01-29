from typing import Optional
import re
from datetime import datetime, timezone

from schemas.identify import IdentifyResponse, IdentifyRequest, AgeBracket
from services.cache import get as cache_get, set as cache_set
from services.gemini import gemini_identify
from db import queries

CONFIRM_THRESHOLD = 0.65


def normalize_interests(interests: list[str], max_n: int = 8) -> list[str]:
    cleaned = []
    seen = set()
    for s in interests:
        t = s.strip().lower()
        if not t:
            continue
        if t in seen:
            continue
        seen.add(t)
        cleaned.append(t)
        if len(cleaned) >= max_n:
            break
    return cleaned


def looks_uncertain(text: str) -> bool:
    uncertain_patterns = [
        r"\bmaybe\b", r"\bpossibly\b", r"\bnot sure\b", r"\bunsure\b", r"\blikely\b", r"\blooks like\b",
    ]
    t = text.lower()
    return any(re.search(p, t) for p in uncertain_patterns)


def safe_lists(res: IdentifyResponse) -> IdentifyResponse:
    # ensure lists exist and cap size
    res.tags = res.tags or []
    res.tags = res.tags[:6]

    res.suggested_questions = res.suggested_questions or []
    res.suggested_questions = res.suggested_questions[:3]

    res.fun_facts.match_facts = res.fun_facts.match_facts or []
    res.fun_facts.discovery_facts = res.fun_facts.discovery_facts or []

    # cap fact counts
    res.fun_facts.match_facts = res.fun_facts.match_facts[:2]
    res.fun_facts.discovery_facts = res.fun_facts.discovery_facts[:2]

    # candidates
    res.candidates = res.candidates or []
    res.candidates = res.candidates[:3]

    return res


def finalize_confidence(res: IdentifyResponse, final_interests: list[str]) -> IdentifyResponse:
    # if Gemini didn't provide a score, infer a rough one
    if res.confidence_score is None:
        low = (not res.landmark_name) or (res.landmark_name.lower() in {"unknown", "uncertain"})
        if low or looks_uncertain(res.description):
            res.confidence_score = 0.55
        else:
            res.confidence_score = 0.80

    # decide confirmation
    if res.confidence_score < CONFIRM_THRESHOLD:
        res.needs_confirmation = True
        if not res.candidates:
            # at least include landmark_name
            if res.landmark_name:
                res.candidates = [res.landmark_name]
    else:
        res.needs_confirmation = False

    # matched_interest should reflect only interests that actually appear in tags
    tags_text = " ".join(res.tags).lower()
    matched = [i for i in final_interests if i in tags_text]
    res.personalization.matched_interest = matched

    return res

async def identify_landmark(
    image_bytes: bytes,
    user_id: Optional[str],
    age_bracket: Optional[AgeBracket],
    interests: list[str],
    lat: Optional[float],
    lng: Optional[float],
    mime_type: str = "image/jpeg",
) -> IdentifyResponse:
    timestamp = datetime.now(timezone.utc)

    # resolve final profile - user input takes priority, profile is fallback
    final_age: AgeBracket = age_bracket or "adult"
    final_interests = normalize_interests(interests)

    if user_id:
        profile = queries.get_profile(user_id)
        if profile:
            # only use profile values if user didn't provide them
            if not age_bracket:
                final_age = profile.get("age_bracket") or final_age
            if not interests:
                final_interests = normalize_interests(profile.get("interests", []))

    # make cache key
    sample = image_bytes[:64]
    cache_key = f"identify:{final_age}:{','.join(final_interests)}:{len(image_bytes)}:{sample.hex()}"

    cached = cache_get(cache_key)
    if cached:
        return cached

    # call Gemini API
    req = IdentifyRequest(user_id=user_id, age_bracket=final_age, interests=final_interests)
    res = gemini_identify(image_bytes=image_bytes, mime_type=mime_type, req=req)

    # post-process safety + confidence/confirmation logic
    res = safe_lists(res)
    res = finalize_confidence(res, final_interests)

    # cache result for 1hr
    cache_set(cache_key, res, ttl_seconds=60 * 60)

    # save scan to DB
    if user_id:
        queries.save_scan(
            user_id=user_id,
            landmark_name=res.landmark_name,
            description=res.description,
            lat=lat,
            lng=lng,
            tags=res.tags,
            timestamp=timestamp,
        )

    return res
