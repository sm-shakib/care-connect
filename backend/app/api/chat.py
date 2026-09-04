from datetime import datetime, timezone
from typing import List, Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.api import chat_ws, deps
from app.core import crypto
from app.core.media import upload_chat_file
from app.db.session import get_db
from app.models.binding import FamilyElderLink
from app.models.booking import Booking
from app.models.chat import Conversation, ConversationParticipant, Message, MessageAttachment
from app.models.user import User
from app.schemas.chat import (
    AddMembersIn,
    AttachmentOut,
    ConversationOut,
    CreateDirectConversationIn,
    CreateGroupConversationIn,
    MessageOut,
    MuteIn,
)

router = APIRouter(prefix="/chat", tags=["Chat"])

_ROLE_MAP = {"elder": "elderly", "caregiver": "caregiver", "family": "family", "admin": "admin"}
_AVATAR_COLORS = {
    "elderly": "#CCFBF1",
    "caregiver": "#8FA7FE",
    "family": "#DCE1FF",
    "admin": "#CCFBF1",
}
_DEFAULT_GROUP_COLOR = "#CCFBF1"


# ==================== identity & contacts ====================


def resolve_identity(db: Session, user: User) -> dict:
    role = _ROLE_MAP.get(user.role, "family")
    name = user.email
    if user.role == "elder" and user.elder_profile:
        name = user.elder_profile.name
    elif user.role == "caregiver" and user.caregiver_profile:
        name = user.caregiver_profile.name
    elif user.role == "family" and user.family_profile:
        name = user.family_profile.name
    return {
        "id": str(user.id),
        "name": name,
        "role": role,
        "avatar_color": _AVATAR_COLORS.get(role, _DEFAULT_GROUP_COLOR),
        "is_online": chat_ws.manager.is_online(user.id),
    }


def get_contacts(db: Session, user: User) -> List[User]:
    """People `user` is allowed to start a chat with, derived from their
    real relationships: accepted family<->elder bindings and accepted
    elder<->caregiver bookings (with family<->caregiver following
    transitively through a shared elder)."""
    contacts: dict = {}

    def add(u: Optional[User]) -> None:
        if u and u.id != user.id:
            contacts[u.id] = u

    if user.role == "family" and user.family_profile:
        links = [l for l in user.family_profile.elder_links if l.status == "accepted"]
        elder_ids = []
        for link in links:
            if link.elder:
                elder_ids.append(link.elder.id)
                add(link.elder.user)
        if elder_ids:
            bookings = (
                db.query(Booking)
                .filter(Booking.elder_id.in_(elder_ids), Booking.status == "accepted")
                .all()
            )
            for booking in bookings:
                if booking.caregiver:
                    add(booking.caregiver.user)

    elif user.role == "elder" and user.elder_profile:
        elder = user.elder_profile
        for link in elder.family_links:
            if link.status == "accepted" and link.family:
                add(link.family.user)
        bookings = (
            db.query(Booking)
            .filter(Booking.elder_id == elder.id, Booking.status == "accepted")
            .all()
        )
        for booking in bookings:
            if booking.caregiver:
                add(booking.caregiver.user)

    elif user.role == "caregiver" and user.caregiver_profile:
        caregiver = user.caregiver_profile
        bookings = (
            db.query(Booking)
            .filter(Booking.caregiver_id == caregiver.id, Booking.status == "accepted")
            .all()
        )
        elder_ids = []
        for booking in bookings:
            if booking.elder:
                elder_ids.append(booking.elder.id)
                add(booking.elder.user)
        if elder_ids:
            links = (
                db.query(FamilyElderLink)
                .filter(
                    FamilyElderLink.elder_id.in_(elder_ids),
                    FamilyElderLink.status == "accepted",
                )
                .all()
            )
            for link in links:
                if link.family:
                    add(link.family.user)

    return list(contacts.values())


# ==================== serialization helpers ====================


def _other_active_participants(conversation: Conversation, exclude_user_id: int):
    return [
        p
        for p in conversation.participants
        if p.user_id != exclude_user_id and p.left_at is None
    ]


def _message_status(conversation: Conversation, message: Message) -> str:
    others = _other_active_participants(conversation, message.sender_id)
    if not others:
        return "sent"
    if all(p.last_read_at and p.last_read_at >= message.created_at for p in others):
        return "read"
    if any(p.last_read_at is not None for p in others):
        return "delivered"
    return "sent"


def _sender_identity(db: Session, message: Message) -> dict:
    sender = message.sender or db.query(User).filter(User.id == message.sender_id).first()
    return resolve_identity(db, sender) if sender else {"id": str(message.sender_id), "name": "Unknown"}


def _decrypt_text(db: Session, conversation_id: int, message: Message) -> Optional[str]:
    if not message.ciphertext:
        return None
    data_key = crypto.get_or_create_conversation_key(db, conversation_id)
    return crypto.decrypt_text(data_key, message.ciphertext)


def _reply_preview(db: Session, conversation: Conversation, message: Message) -> Optional[dict]:
    """A shallow snapshot of the message being replied to (no attachments,
    no further reply chain) — just enough to render a quoted preview."""
    original = message.reply_to
    if original is None:
        return None
    identity = _sender_identity(db, original)
    is_deleted = original.deleted_at is not None
    return {
        "id": original.id,
        "sender_id": identity["id"],
        "sender_name": identity["name"],
        "type": original.type,
        "text": None if is_deleted else _decrypt_text(db, conversation.id, original),
        "is_deleted": is_deleted,
    }


def serialize_message(db: Session, conversation: Conversation, message: Message) -> dict:
    is_deleted = message.deleted_at is not None
    sender_identity = _sender_identity(db, message)

    return {
        "id": message.id,
        "conversation_id": message.conversation_id,
        "sender_id": sender_identity["id"],
        "sender_name": sender_identity["name"],
        "type": message.type,
        "text": None if is_deleted else _decrypt_text(db, conversation.id, message),
        "attachments": []
        if is_deleted
        else [
            {
                "id": a.id,
                "kind": a.kind,
                "file_name": a.file_name,
                "url": a.url,
                "mime_type": a.mime_type,
                "size_bytes": a.size_bytes,
                "duration_ms": a.duration_ms,
                "width": a.width,
                "height": a.height,
            }
            for a in message.attachments
        ],
        "status": _message_status(conversation, message),
        # isoformat string, not a raw datetime: this dict is also sent
        # verbatim over the WebSocket (json.dumps can't handle datetime),
        # and Pydantic's `datetime` field parses the string back on the
        # REST responses that use MessageOut.
        "created_at": message.created_at.isoformat(),
        "call_is_video": message.call_is_video,
        "call_outcome": message.call_outcome,
        "call_duration_seconds": message.call_duration_seconds,
        "reply_to": _reply_preview(db, conversation, message),
        "is_deleted": is_deleted,
    }


def _last_message(db: Session, conversation_id: int) -> Optional[Message]:
    return (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id)
        .order_by(Message.created_at.desc())
        .first()
    )


def _conversation_payload(db: Session, conversation: Conversation, viewer_id: int) -> dict:
    participant = next((p for p in conversation.participants if p.user_id == viewer_id), None)
    last = _last_message(db, conversation.id)

    unread_query = db.query(Message).filter(Message.conversation_id == conversation.id)
    if participant is None:
        unread = 0
    elif participant.last_read_at is not None:
        unread = unread_query.filter(Message.created_at > participant.last_read_at).count()
    else:
        unread = unread_query.count()

    return {
        "id": conversation.id,
        "is_group": conversation.is_group,
        "title": conversation.title,
        "avatar_color": conversation.avatar_color or _DEFAULT_GROUP_COLOR,
        "created_by": str(conversation.created_by) if conversation.created_by else None,
        "is_muted": participant.is_muted if participant else False,
        "unread_count": unread,
        "participants": [
            resolve_identity(db, p.user) for p in conversation.participants if p.left_at is None
        ],
        "last_message": serialize_message(db, conversation, last) if last else None,
    }


def _get_conversation_and_participant(db: Session, conversation_id: int, user: User):
    conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    participant = next(
        (p for p in conversation.participants if p.user_id == user.id and p.left_at is None),
        None,
    )
    if not participant:
        raise HTTPException(status_code=403, detail="Not a participant of this conversation")
    return conversation, participant


def _attachment_kind_for(message_type: str, content_type: Optional[str]) -> str:
    if message_type in ("image", "video", "document", "voice"):
        return message_type
    if content_type:
        if content_type.startswith("image/"):
            return "image"
        if content_type.startswith("video/"):
            return "video"
        if content_type.startswith("audio/"):
            return "voice"
    return "document"


# ==================== identity & contacts endpoints ====================


@router.get("/me")
def get_me(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    return resolve_identity(db, current_user)


@router.get("/contacts")
def list_contacts(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    return [resolve_identity(db, u) for u in get_contacts(db, current_user)]


# ==================== conversations ====================


@router.get("/conversations", response_model=List[ConversationOut])
def list_conversations(
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    rows = (
        db.query(ConversationParticipant)
        .filter(
            ConversationParticipant.user_id == current_user.id,
            ConversationParticipant.left_at.is_(None),
            ConversationParticipant.hidden_at.is_(None),
        )
        .all()
    )
    payloads = [_conversation_payload(db, row.conversation, current_user.id) for row in rows]
    epoch = datetime.min.replace(tzinfo=timezone.utc)
    payloads.sort(
        key=lambda c: c["last_message"]["created_at"] if c["last_message"] else epoch,
        reverse=True,
    )
    return payloads


@router.post("/conversations/direct", response_model=ConversationOut)
def create_direct_conversation(
    body: CreateDirectConversationIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    if body.other_user_id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot start a conversation with yourself")
    other = db.query(User).filter(User.id == body.other_user_id).first()
    if not other:
        raise HTTPException(status_code=404, detail="User not found")

    contact_ids = {u.id for u in get_contacts(db, current_user)}
    if other.id not in contact_ids:
        raise HTTPException(
            status_code=403, detail="You can only message people you're connected with"
        )

    candidates = (
        db.query(Conversation)
        .join(ConversationParticipant)
        .filter(Conversation.is_group.is_(False))
        .filter(ConversationParticipant.user_id.in_([current_user.id, other.id]))
        .all()
    )
    for conversation in candidates:
        member_ids = {p.user_id for p in conversation.participants if p.left_at is None}
        if member_ids == {current_user.id, other.id}:
            return _conversation_payload(db, conversation, current_user.id)

    conversation = Conversation(is_group=False, created_by=current_user.id)
    db.add(conversation)
    db.flush()
    db.add(
        ConversationParticipant(conversation_id=conversation.id, user_id=current_user.id, role="admin")
    )
    db.add(ConversationParticipant(conversation_id=conversation.id, user_id=other.id, role="member"))
    db.commit()
    db.refresh(conversation)
    return _conversation_payload(db, conversation, current_user.id)


@router.post("/conversations/group", response_model=ConversationOut)
def create_group_conversation(
    body: CreateGroupConversationIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    contact_ids = {u.id for u in get_contacts(db, current_user)}
    member_ids = set(body.member_ids) - {current_user.id}
    invalid = member_ids - contact_ids
    if invalid:
        raise HTTPException(status_code=403, detail="Some members are not in your contacts")

    conversation = Conversation(is_group=True, title=body.title, created_by=current_user.id)
    db.add(conversation)
    db.flush()
    db.add(
        ConversationParticipant(conversation_id=conversation.id, user_id=current_user.id, role="admin")
    )
    for member_id in member_ids:
        db.add(ConversationParticipant(conversation_id=conversation.id, user_id=member_id, role="member"))
    db.commit()
    db.refresh(conversation)
    return _conversation_payload(db, conversation, current_user.id)


@router.get("/conversations/{conversation_id}", response_model=ConversationOut)
def get_conversation(
    conversation_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, _ = _get_conversation_and_participant(db, conversation_id, current_user)
    return _conversation_payload(db, conversation, current_user.id)


@router.patch("/conversations/{conversation_id}/mute")
def set_muted(
    conversation_id: int,
    body: MuteIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    _, participant = _get_conversation_and_participant(db, conversation_id, current_user)
    participant.is_muted = body.is_muted
    db.commit()
    return {"ok": True}


@router.delete("/conversations/{conversation_id}")
def delete_conversation(
    conversation_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    """Hides the conversation for the caller only — mirrors "Delete chat"
    in the frontend, which is explicitly per-device, not per-everyone."""
    _, participant = _get_conversation_and_participant(db, conversation_id, current_user)
    participant.hidden_at = datetime.now(timezone.utc)
    db.commit()
    return {"ok": True}


@router.post("/conversations/{conversation_id}/members", response_model=ConversationOut)
async def add_members(
    conversation_id: int,
    body: AddMembersIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, _ = _get_conversation_and_participant(db, conversation_id, current_user)
    if not conversation.is_group:
        raise HTTPException(status_code=400, detail="Cannot add members to a direct conversation")

    contact_ids = {u.id for u in get_contacts(db, current_user)}
    existing_ids = {p.user_id for p in conversation.participants if p.left_at is None}
    to_add = set(body.member_ids) - existing_ids - {current_user.id}
    invalid = to_add - contact_ids
    if invalid:
        raise HTTPException(status_code=403, detail="Some members are not in your contacts")

    for member_id in to_add:
        db.add(ConversationParticipant(conversation_id=conversation.id, user_id=member_id, role="member"))
    db.commit()
    db.refresh(conversation)

    payload = _conversation_payload(db, conversation, current_user.id)
    await chat_ws.manager.broadcast_to_conversation(
        conversation, {"type": "conversation:updated", "conversation": payload}
    )
    return payload


@router.delete("/conversations/{conversation_id}/members/{member_id}", response_model=ConversationOut)
async def remove_member(
    conversation_id: int,
    member_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, participant = _get_conversation_and_participant(db, conversation_id, current_user)
    if not conversation.is_group:
        raise HTTPException(status_code=400, detail="Cannot remove members from a direct conversation")

    is_self = member_id == current_user.id
    is_admin = participant.role == "admin" or conversation.created_by == current_user.id
    if not is_self and not is_admin:
        raise HTTPException(status_code=403, detail="Only the group admin can remove other members")

    target = next(
        (p for p in conversation.participants if p.user_id == member_id and p.left_at is None), None
    )
    if not target:
        raise HTTPException(status_code=404, detail="Member not found")

    target.left_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(conversation)

    payload = _conversation_payload(db, conversation, current_user.id)
    await chat_ws.manager.broadcast_to_conversation(
        conversation, {"type": "conversation:updated", "conversation": payload}
    )
    return payload


# ==================== messages ====================


@router.get("/conversations/{conversation_id}/messages", response_model=List[MessageOut])
def list_messages(
    conversation_id: int,
    before: Optional[int] = None,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, _ = _get_conversation_and_participant(db, conversation_id, current_user)
    query = db.query(Message).filter(Message.conversation_id == conversation_id)
    if before:
        anchor = db.query(Message).filter(Message.id == before).first()
        if anchor:
            query = query.filter(Message.created_at < anchor.created_at)
    messages = query.order_by(Message.created_at.desc()).limit(min(limit, 200)).all()
    messages.reverse()
    return [serialize_message(db, conversation, m) for m in messages]


@router.post("/conversations/{conversation_id}/messages", response_model=MessageOut)
async def send_message(
    conversation_id: int,
    type: str = Form("text"),
    text: Optional[str] = Form(None),
    reply_to_message_id: Optional[int] = Form(None),
    files: List[UploadFile] = File(default=[]),
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, _ = _get_conversation_and_participant(db, conversation_id, current_user)

    text = text.strip() if text else None
    if not text and not files:
        raise HTTPException(status_code=400, detail="Message must have text or at least one attachment")

    if reply_to_message_id is not None:
        original = (
            db.query(Message)
            .filter(Message.id == reply_to_message_id, Message.conversation_id == conversation_id)
            .first()
        )
        if not original:
            raise HTTPException(status_code=404, detail="Message being replied to was not found")

    ciphertext = None
    if text:
        data_key = crypto.get_or_create_conversation_key(db, conversation_id)
        ciphertext = crypto.encrypt_text(data_key, text)

    message = Message(
        conversation_id=conversation_id,
        sender_id=current_user.id,
        type=type,
        ciphertext=ciphertext,
        reply_to_message_id=reply_to_message_id,
    )
    db.add(message)
    db.flush()

    for upload in files:
        result = upload_chat_file(upload)
        duration = result.get("duration")
        db.add(
            MessageAttachment(
                message_id=message.id,
                kind=_attachment_kind_for(type, upload.content_type),
                file_name=upload.filename or "file",
                url=result.get("secure_url"),
                public_id=result.get("public_id"),
                mime_type=upload.content_type,
                size_bytes=result.get("bytes", 0),
                duration_ms=int(duration * 1000) if duration else None,
                width=result.get("width"),
                height=result.get("height"),
            )
        )

    # A new message revives the conversation for anyone who'd hidden it.
    for participant in conversation.participants:
        participant.hidden_at = None

    db.commit()
    db.refresh(message)

    payload = serialize_message(db, conversation, message)
    await chat_ws.manager.broadcast_to_conversation(
        conversation,
        {"type": "message:new", "conversation_id": conversation_id, "message": payload},
        exclude_user_id=current_user.id,
    )
    return payload


@router.delete("/conversations/{conversation_id}/messages/{message_id}", response_model=MessageOut)
async def unsend_message(
    conversation_id: int,
    message_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    """"Unsend" — only the sender may do this, and only for their own
    message. The row stays (so ordering and any replies to it survive, see
    `Message.reply_to_message_id`'s ON DELETE SET NULL) but its content is
    wiped and it renders as "This message was unsent" for everyone,
    matching WhatsApp/Messenger's behavior rather than a silent local-only
    delete."""
    conversation, _ = _get_conversation_and_participant(db, conversation_id, current_user)
    message = (
        db.query(Message)
        .filter(Message.id == message_id, Message.conversation_id == conversation_id)
        .first()
    )
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")
    if message.sender_id != current_user.id:
        raise HTTPException(status_code=403, detail="You can only unsend your own messages")

    message.deleted_at = datetime.now(timezone.utc)
    message.ciphertext = None
    for attachment in list(message.attachments):
        db.delete(attachment)
    db.commit()
    db.refresh(message)

    payload = serialize_message(db, conversation, message)
    await chat_ws.manager.broadcast_to_conversation(
        conversation,
        {"type": "message:deleted", "conversation_id": conversation_id, "message": payload},
    )
    return payload


@router.put("/conversations/{conversation_id}/read")
async def mark_read(
    conversation_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, participant = _get_conversation_and_participant(db, conversation_id, current_user)
    now = datetime.now(timezone.utc)

    newly_read_query = db.query(Message).filter(
        Message.conversation_id == conversation_id,
        Message.sender_id != current_user.id,
    )
    if participant.last_read_at is not None:
        newly_read_query = newly_read_query.filter(Message.created_at > participant.last_read_at)
    newly_read_senders = {m.sender_id for m in newly_read_query.all()}

    participant.last_read_at = now
    db.commit()

    for sender_id in newly_read_senders:
        await chat_ws.manager.send_to_user(
            sender_id,
            {
                "type": "message:read",
                "conversation_id": conversation_id,
                "reader_id": str(current_user.id),
            },
        )
    return {"ok": True}


@router.get("/conversations/{conversation_id}/search", response_model=List[MessageOut])
def search_messages(
    conversation_id: int,
    q: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    conversation, _ = _get_conversation_and_participant(db, conversation_id, current_user)
    needle = q.strip().lower()
    if not needle:
        return []

    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id, Message.ciphertext.isnot(None))
        .order_by(Message.created_at.asc())
        .all()
    )
    data_key = crypto.get_or_create_conversation_key(db, conversation_id)
    matches = []
    for message in messages:
        plaintext = crypto.decrypt_text(data_key, message.ciphertext)
        if needle in plaintext.lower():
            matches.append(serialize_message(db, conversation, message))
    return matches


@router.get("/conversations/{conversation_id}/media", response_model=List[AttachmentOut])
def list_media(
    conversation_id: int,
    kind: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(deps.get_current_active_user),
):
    _get_conversation_and_participant(db, conversation_id, current_user)
    query = (
        db.query(MessageAttachment)
        .join(Message, Message.id == MessageAttachment.message_id)
        .filter(Message.conversation_id == conversation_id)
    )
    if kind:
        query = query.filter(MessageAttachment.kind == kind)
    return query.order_by(Message.created_at.desc()).all()
