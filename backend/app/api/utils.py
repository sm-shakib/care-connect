from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import cloudinary
import cloudinary.uploader
from app.core.config import settings

# Configure Cloudinary (Move these to core/config.py later if you prefer)
cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET"),
    secure=True
)

router = APIRouter()

@router.post("/upload")
async def upload_image(file: UploadFile = File(...)):
    try:
        # Use resource_type="auto" to support PDF, DOC, and images automatically
        result = cloudinary.uploader.upload(
            file.file, 
            resource_type="auto"
        )
        return {"url": result.get("secure_url")}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")