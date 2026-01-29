from google import genai
from google.genai import types
from schemas.identify import IdentifyRequest, IdentifyResponse
import os


def gemini_identify(image_bytes: bytes, mime_type: str, req: IdentifyRequest) -> IdentifyResponse:
    client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
    interests = ", ".join(req.interests) if req.interests else "None"
    age_bracket = req.age_bracket

    prompt = f"""
    You are a travel guide and landmark identifier.

    USER PROFILE:
    - age_bracket: {age_bracket}
    - interests: {interests}

    TASK:
    1) Identify the landmark/building/place in the image as best as you can.
    2) Generate personalized info based on age_bracket + interests.
    3) Output MUST be valid JSON that matches the provided JSON schema EXACTLY.
    4) If you are not confident, set:
    - needs_confirmation = true
    - candidates = up to 3 plausible landmark names
    - confidence_score <= 0.6
    - still fill other fields as best as you can.

    CONTENT RULES:
    - description: 1 short paragraph, adjusted to age_bracket reading level.
    - tags: 3–6 short tags relevant to the place (e.g. "history", "architecture", "museum", "nature").
    - fun_facts, which has two subfields match_facts and discovery_facts:
    - match_facts: 1–2 facts explicitly tied to user interests (empty list if no match).
    - discovery_facts: 1–2 general surprising facts (always try to provide).
    - suggested_questions: 3 short follow-up questions the user can tap (age + interests aware).
    - location: city/country if known, otherwise a best guess or "Unknown".

    Return ONLY JSON. No markdown. No extra keys.
    """.strip()
    image_part = types.Part.from_bytes(data=image_bytes, mime_type=mime_type)

    response = client.models.generate_content(
        model="gemini-3-flash-preview",
        contents=[image_part, prompt],
        config=types.GenerateContentConfig(
            thinking_config=types.ThinkingConfig(
                thinking_level=types.ThinkingLevel.LOW
            ),
            max_output_tokens=800,
            response_mime_type="application/json",
            response_json_schema=IdentifyResponse.model_json_schema(),
            media_resolution=types.MediaResolution.MEDIA_RESOLUTION_MEDIUM,
        ),
    )
    text = response.text
    if not text:
        raise ValueError("Gemini response is empty.")
    return IdentifyResponse.model_validate_json(text)