from google import genai
from typing import List, Dict, Tuple
import os
import json

def chat_about_landmark(
    landmark_name: str,
    landmark_info: str,
    conversation_history: List[Dict[str, str]],
    user_message: str
) -> Tuple[str, List[str]]:
    """
    Chat with Gemini about a specific landmark.
    
    Args:
        landmark_name: Name of the landmark
        landmark_info: Description and context about the landmark
        conversation_history: Previous messages in the conversation
        user_message: Current user question
        
    Returns:
        Tuple of (AI response as a string, List of suggested follow-up questions)
    """
    
    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
    
    # Build context prompt
    system_context = f"""You are a knowledgeable tour guide assistant helping users learn about landmarks.

Current Landmark: {landmark_name}
Landmark Information: {landmark_info}

Guidelines:
- Answer questions specifically about {landmark_name}
- Be informative, engaging, and friendly
- Keep responses SHORT and MOBILE-FRIENDLY
- Format your response as BULLET POINTS using emojis that match the content
- Choose emojis that are relevant to each point (e.g., 🏛️ for architecture, 📅 for dates, 👑 for royalty, 🎨 for art, 🏗️ for construction, 🌍 for geography, ⭐ for highlights, 💡 for interesting facts, 📖 for history, 🎭 for culture)
- Start each bullet point with the emoji followed by the information
- Keep each bullet point concise (1-2 sentences)
- Use 3-5 bullet points per response
- If asked about other topics, politely redirect to {landmark_name}
- After your bullet points, suggest 3 relevant follow-up questions users might be interested in
- Format suggested questions as: "SUGGESTED_QUESTIONS: [question1] | [question2] | [question3]"
"""
    
    # Build full conversation prompt
    conversation = [system_context]
    
    # Add conversation history
    for msg in conversation_history:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        if role == "user":
            conversation.append(f"User: {content}")
        else:
            conversation.append(f"Assistant: {content}")
    
    # Add current question
    conversation.append(f"User: {user_message}")
    conversation.append("Assistant:")
    
    # Generate response
    full_prompt = "\n\n".join(conversation)
    
    try:
        response = client.models.generate_content(
            model="gemini-3-flash-preview",
            contents=full_prompt
        )
        if response.text:
            text = response.text.strip()
            
            # Extract suggested questions if present
            suggested_questions = []
            if "SUGGESTED_QUESTIONS:" in text:
                parts = text.split("SUGGESTED_QUESTIONS:")
                main_response = parts[0].strip()
                questions_text = parts[1].strip()
                # Parse questions separated by |
                suggested_questions = [q.strip() for q in questions_text.split("|") if q.strip()]
            else:
                main_response = text
                # Generate default suggestions if AI didn't provide them
                suggested_questions = [
                    f"What is the historical significance of {landmark_name}?",
                    f"Tell me an interesting fact about {landmark_name}",
                    f"When was {landmark_name} built?"
                ]
            
            return main_response, suggested_questions[:3]  # Limit to 3 questions
        else:
            return f"I received an empty response. Please try asking your question about {landmark_name} again.", []
    except Exception as e:
        print(f"Error in chat_service: {e}")
        return f"I'm having trouble answering that question about {landmark_name}. Could you rephrase or ask something else?", []
