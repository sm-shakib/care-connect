from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.session import Base


class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(Integer, primary_key=True, index=True)
    is_group = Column(Boolean, default=False, nullable=False)
    title = Column(String, nullable=True)  # required for groups, ignored for direct chats
    avatar_color = Column(String, nullable=True)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    participants = relationship(
        "ConversationParticipant",
        back_populates="conversation",
        cascade="all, delete-orphan",
    )
    messages = relationship(
        "Message",
        back_populates="conversation",
        cascade="all, delete-orphan",
    )
    key = relationship(
        "ConversationKey",
        back_populates="conversation",
        uselist=False,
        cascade="all, delete-orphan",
    )


class ConversationParticipant(Base):
    __tablename__ = "conversation_participants"
    __table_args__ = (
        UniqueConstraint("conversation_id", "user_id", name="uq_conversation_participant_user"),
    )

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"), nullable=False, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)

    role = Column(String, default="member")  # "admin" or "member" (groups only)
    joined_at = Column(DateTime(timezone=True), server_default=func.now())
    left_at = Column(DateTime(timezone=True), nullable=True)  # removed/left a group
    is_muted = Column(Boolean, default=False)

    # Drives unread counts + per-message read-receipt status.
    last_read_at = Column(DateTime(timezone=True), nullable=True)

    # "Delete chat for me" — cleared automatically when a new message
    # arrives, so a hidden conversation reappears like most chat apps.
    hidden_at = Column(DateTime(timezone=True), nullable=True)

    conversation = relationship("Conversation", back_populates="participants")
    user = relationship("User")


class ConversationKey(Base):
    """The per-conversation AES-256 data key, wrapped with the server's
    master key. See app/core/crypto.py."""

    __tablename__ = "conversation_keys"

    conversation_id = Column(Integer, ForeignKey("conversations.id"), primary_key=True)
    wrapped_key = Column(Text, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    conversation = relationship("Conversation", back_populates="key")


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"), nullable=False, index=True)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)

    # text / image / document / voice / video / call_log
    type = Column(String, default="text", nullable=False)

    # base64(nonce + ciphertext) — see app/core/crypto.py. Null for
    # attachment-only messages and call logs.
    ciphertext = Column(Text, nullable=True)

    # Only populated for type == "call_log".
    call_is_video = Column(Boolean, nullable=True)
    call_outcome = Column(String, nullable=True)  # answered / missed / declined
    call_duration_seconds = Column(Integer, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    conversation = relationship("Conversation", back_populates="messages")
    sender = relationship("User")
    attachments = relationship(
        "MessageAttachment",
        back_populates="message",
        cascade="all, delete-orphan",
    )


class MessageAttachment(Base):
    __tablename__ = "message_attachments"

    id = Column(Integer, primary_key=True, index=True)
    message_id = Column(Integer, ForeignKey("messages.id"), nullable=False, index=True)

    kind = Column(String, nullable=False)  # image / video / document / voice
    file_name = Column(String, nullable=False)
    url = Column(String, nullable=False)
    public_id = Column(String, nullable=True)  # Cloudinary public_id
    mime_type = Column(String, nullable=True)
    size_bytes = Column(Integer, default=0)
    duration_ms = Column(Integer, nullable=True)  # voice/video playback length
    width = Column(Integer, nullable=True)  # image/video pixel dimensions
    height = Column(Integer, nullable=True)

    message = relationship("Message", back_populates="attachments")
