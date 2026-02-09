from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Optional
from backend.services.chat_service import chat_about_landmark

router = APIRouter(prefix="/chat", tags=["chat"])

class ChatMessage(BaseModel):
    role: str  # "user" or "assistant"
    content: str

class ChatRequest(BaseModel):
    landmark_name: str
    landmark_info: str
    conversation_history: List[ChatMessage] = []
    user_message: str
    user_id: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    suggested_questions: List[str] = []

@router.post("/", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """
    Chat endpoint for asking questions about a landmark.
    """
    try:
        # Convert ChatMessage objects to dicts
        history = [{"role": msg.role, "content": msg.content} for msg in request.conversation_history]
        
        # Get AI response with suggested questions
        ai_response, suggested_questions = chat_about_landmark(
            landmark_name=request.landmark_name,
            landmark_info=request.landmark_info,
            conversation_history=history,
            user_message=request.user_message
        )
        
        return ChatResponse(response=ai_response, suggested_questions=suggested_questions)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Chat error: {str(e)}")
