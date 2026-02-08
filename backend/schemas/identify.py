from pydantic import BaseModel, Field
from typing import Optional, List, Literal

AgeBracket = Literal["kid", "teen", "adult", "senior"]

class Personalization(BaseModel):
    age_bracket: Optional[AgeBracket] = None
    matched_interest: List[str] = Field(default_factory=list)

class FunFacts(BaseModel):
    match_facts: List[str] = Field(default_factory=list)
    discovery_facts: List[str] = Field(default_factory=list)

class PlaceSuggestion(BaseModel):
    name: str
    address: Optional[str] = None
    rating: Optional[float] = None
    user_ratings_total: Optional[int] = None
    distance_meters: Optional[int] = None
    open_now: Optional[bool] = None
    place_id: Optional[str] = None
    types: List[str] = Field(default_factory=list)
    maps_url: Optional[str] = None

class NearbySuggestions(BaseModel):
    landmarks: List[PlaceSuggestion] = Field(default_factory=list)
    food: List[PlaceSuggestion] = Field(default_factory=list)

class EventSuggestion(BaseModel):
    name: str
    start_time: Optional[str] = None
    venue: Optional[str] = None
    address: Optional[str] = None
    distance_meters: Optional[int] = None
    category: Optional[str] = None
    url: Optional[str] = None

class IdentifyRequest(BaseModel):
    user_id: Optional[str] = None
    age_bracket: Optional[AgeBracket] = None
    interests: List[str] = Field(default_factory=list)

class IdentifyResponse(BaseModel):
    landmark_name: str
    location: str
    landmark_lat: Optional[float] = None
    landmark_lng: Optional[float] = None
    tags: List[str]
    description: str
    
    personalization: Personalization
    fun_facts: FunFacts

    suggested_questions: List[str] = Field(default_factory=list)

    nearby: Optional[NearbySuggestions] = None
    events: List[EventSuggestion] = Field(default_factory=list)

    confidence_score: Optional[float] = None
    needs_confirmation: Optional[bool] = False
    candidates: Optional[List[str]] = None
    scan_id: Optional[str] = None