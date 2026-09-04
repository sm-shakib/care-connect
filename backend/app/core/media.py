"""Shared Cloudinary upload helper for chat attachments.

Mirrors the configuration/upload pattern already used in
`app/api/utils.py` for caregiver document uploads, factored out so the
chat message endpoint can reuse it without duplicating the Cloudinary
config block.
"""
import os

import cloudinary
import cloudinary.uploader
from fastapi import UploadFile

cloudinary.config(
    cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
    api_key=os.getenv("CLOUDINARY_API_KEY"),
    api_secret=os.getenv("CLOUDINARY_API_SECRET"),
    secure=True,
)


def upload_chat_file(file: UploadFile) -> dict:
    """Uploads an image/video/audio/document to Cloudinary and returns the
    raw upload result (secure_url, public_id, bytes, duration, width,
    height, etc. — whichever the resource type provides)."""
    return cloudinary.uploader.upload(file.file, resource_type="auto")
