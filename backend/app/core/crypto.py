"""Server-side encryption at rest for chat message text.

Uses envelope encryption with AES-256-GCM (via the `cryptography` package):
each conversation gets its own random 256-bit data key, which is itself
encrypted ("wrapped") with a single server-wide master key before being
stored in `conversation_keys`. Message text is encrypted with the
conversation's data key. This keeps a master-key rotation cheap (only the
small `conversation_keys` table needs re-wrapping) while still meaning a
raw database dump never reveals plaintext message content.

This protects data at rest — the backend itself still has the keys needed
to decrypt (required to keep search, previews, and multi-device sync
working). It is not end-to-end encryption.
"""
import base64
import os

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.chat import ConversationKey

_NONCE_LEN = 12  # bytes, the standard/recommended nonce size for AES-GCM


def _master_key() -> bytes:
    return base64.b64decode(settings.CHAT_MASTER_KEY)


def _wrap_key(data_key: bytes) -> str:
    aesgcm = AESGCM(_master_key())
    nonce = os.urandom(_NONCE_LEN)
    wrapped = aesgcm.encrypt(nonce, data_key, None)
    return base64.b64encode(nonce + wrapped).decode("ascii")


def _unwrap_key(wrapped_b64: str) -> bytes:
    raw = base64.b64decode(wrapped_b64)
    nonce, ciphertext = raw[:_NONCE_LEN], raw[_NONCE_LEN:]
    aesgcm = AESGCM(_master_key())
    return aesgcm.decrypt(nonce, ciphertext, None)


def get_or_create_conversation_key(db: Session, conversation_id: int) -> bytes:
    """Returns the (unwrapped) AES data key for a conversation, generating
    and persisting one on first use."""
    row = (
        db.query(ConversationKey)
        .filter(ConversationKey.conversation_id == conversation_id)
        .first()
    )
    if row:
        return _unwrap_key(row.wrapped_key)

    data_key = AESGCM.generate_key(bit_length=256)
    db.add(
        ConversationKey(
            conversation_id=conversation_id,
            wrapped_key=_wrap_key(data_key),
        )
    )
    db.commit()
    return data_key


def encrypt_text(data_key: bytes, plaintext: str) -> str:
    """Returns base64(nonce + ciphertext+tag), ready to store as a single
    text column."""
    aesgcm = AESGCM(data_key)
    nonce = os.urandom(_NONCE_LEN)
    ciphertext = aesgcm.encrypt(nonce, plaintext.encode("utf-8"), None)
    return base64.b64encode(nonce + ciphertext).decode("ascii")


def decrypt_text(data_key: bytes, blob_b64: str) -> str:
    raw = base64.b64decode(blob_b64)
    nonce, ciphertext = raw[:_NONCE_LEN], raw[_NONCE_LEN:]
    aesgcm = AESGCM(data_key)
    return aesgcm.decrypt(nonce, ciphertext, None).decode("utf-8")
