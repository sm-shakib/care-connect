from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel


class ParticipantOut(BaseModel):
    id: str
    name: str
    role: str
    avatar_color: str
    is_online: bool = False


class AttachmentOut(BaseModel):
    id: int
    kind: str
    file_name: str
    url: str
    mime_type: Optional[str] = None
    size_bytes: int = 0
    duration_ms: Optional[int] = None
    width: Optional[int] = None
    height: Optional[int] = None

    class Config:
        from_attributes = True


class ReplyPreviewOut(BaseModel):
    """A lightweight snapshot of the message being replied to — enough to
    render a quoted preview, without recursing into its own reply chain."""

    id: int
    sender_id: str
    sender_name: str
    type: str
    text: Optional[str] = None
    is_deleted: bool = False


class MessageOut(BaseModel):
    id: int
    conversation_id: int
    sender_id: str
    sender_name: str
    type: str
    text: Optional[str] = None
    attachments: List[AttachmentOut] = []
    status: str  # sent / delivered / read
    created_at: datetime
    call_is_video: Optional[bool] = None
    call_outcome: Optional[str] = None
    call_duration_seconds: Optional[int] = None
    reply_to: Optional[ReplyPreviewOut] = None
    is_deleted: bool = False


class ConversationOut(BaseModel):
    id: int
    is_group: bool
    title: Optional[str] = None
    avatar_color: str
    created_by: Optional[str] = None
    is_muted: bool = False
    unread_count: int = 0
    participants: List[ParticipantOut]
    last_message: Optional[MessageOut] = None


class CreateDirectConversationIn(BaseModel):
    other_user_id: int


class CreateGroupConversationIn(BaseModel):
    title: str
    member_ids: List[int]


class AddMembersIn(BaseModel):
    member_ids: List[int]


class MuteIn(BaseModel):
    is_muted: bool
