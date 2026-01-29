from pydantic import BaseModel, Field
from typing import Optional, List, Literal

AgeBracket = Literal["child", "teen", "adult", "senior"]

class Personalization(BaseModel):
    age_bracket: Optional[AgeBracket] = None
    matched_interest: List[str] = Field(default_factory=list)

class FunFacts(BaseModel):
    match_facts: List[str] = Field(default_factory=list)
    discovery_facts: List[str] = Field(default_factory=list)

class IdentifyRequest(BaseModel):
    user_id: Optional[str] = None
    age_bracket: Optional[AgeBracket] = None
    interests: List[str] = Field(default_factory=list)

class IdentifyResponse(BaseModel):
    landmark_name: str
    location: str
    tags: List[str]
    description: str
    
    personalization: Personalization
    fun_facts: FunFacts

    suggested_questions: List[str] = Field(default_factory=list)

    confidence_score: Optional[float] = None
    needs_confirmation: Optional[bool] = False
    candidates: Optional[List[str]] = None

