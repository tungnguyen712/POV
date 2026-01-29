from fastapi import APIRouter, UploadFile, File, HTTPException, Form
from schemas.identify import IdentifyResponse, AgeBracket
from services.identify_service import identify_landmark
from typing import Optional

router = APIRouter(prefix="/identify", tags=["Identify"])

@router.post("/", response_model=IdentifyResponse)
async def identify_route(
        image: UploadFile = File(...),
        user_id: Optional[str] = Form(default=None),
        age_bracket: Optional[AgeBracket] = Form(default=None),
        interests: Optional[str] = Form(default=None),
        lat: Optional[float] = Form(default=None),
        lng: Optional[float] = Form(default=None),
):
    
    # image file validation - check both content_type and filename
    allowed_types = ["image/jpeg", "image/jpg", "image/png", "application/octet-stream"]
    filename_lower = image.filename.lower() if image.filename else ""
    allowed_extensions = ['.jpg', '.jpeg', '.png']
    
    has_valid_extension = any(filename_lower.endswith(ext) for ext in allowed_extensions)
    has_valid_content_type = image.content_type in allowed_types
    
    if not (has_valid_content_type and has_valid_extension):
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid image format. Filename: {image.filename}, Content-Type: {image.content_type}"
        )
    
    # Determine actual MIME type from extension
    if filename_lower.endswith('.png'):
        actual_mime_type = "image/png"
    else:  # .jpg or .jpeg
        actual_mime_type = "image/jpeg"
    
    image_bytes = await image.read()
    if len(image_bytes) == 0:
        raise HTTPException(status_code=400, detail="Empty image.")
    max_mb = 8
    if len(image_bytes) > max_mb * 1024 * 1024:
        raise HTTPException(status_code=400, detail=f"Files too large. {max_mb} MB limit.")
    
    # parse interests list
    interests_list = interests.split(",") if interests else []

    try:
        res: IdentifyResponse = await identify_landmark(
            image_bytes=image_bytes,
            mime_type=actual_mime_type,
            user_id=user_id,
            age_bracket=age_bracket,
            interests=interests_list,
            lat=lat,
            lng=lng,
        )
        return res
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Identify failed: {str(e)}")