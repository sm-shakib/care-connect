"""Real-time transport for chat: one WebSocket per connected device.

Handles two jobs:
- Relaying `message:new` / `message:read` / `conversation:updated` pushes
  that the REST handlers in `app/api/chat.py` hand it after writing to the
  database (see `ConnectionManager.send_to_user` /
  `broadcast_to_conversation`).
- WebRTC call signaling: `call:*` envelopes are relayed verbatim between
  the participants of a conversation — this endpoint never looks at SDP
  contents, it just routes them to whoever is online. When a call ends
  with an outcome, it also persists a `call_log` message so the call shows
  up in history for every participant, the same way `message:new` does.
- `ping` -> `pong`: the client's heartbeat (see `ChatSocketService`), used
  to detect a dead-but-not-yet-closed connection and force a reconnect.

Everything is in-memory (a `dict[user_id, set[WebSocket]]`), which is fine
since this app runs as a single process; a multi-instance deployment would
need to swap this for a shared pub/sub (e.g. Redis).
"""
import json
from typing import Dict, Optional, Set

from fastapi import APIRouter, Query, WebSocket, WebSocketDisconnect
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import SessionLocal
from app.models.chat import Conversation, Message
from app.models.user import User

router = APIRouter()

_CALL_AND_PRESENCE_EVENTS = {
    "typing",
    "call:invite",  # ring: broadcast, no SDP yet
    "call:ready",  # "I've accepted/placed the call — offer me a connection"
    "call:offer",
    "call:answer",
    "call:ice",
    "call:leave",  # one participant dropping out of an ongoing group call
    "call:end",  # the call is over for everyone (always carries `outcome`)
}


class ConnectionManager:
    def __init__(self) -> None:
        self._connections: Dict[int, Set[WebSocket]] = {}

    def is_online(self, user_id: int) -> bool:
        return bool(self._connections.get(user_id))

    async def connect(self, user_id: int, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections.setdefault(user_id, set()).add(websocket)

    def disconnect(self, user_id: int, websocket: WebSocket) -> None:
        sockets = self._connections.get(user_id)
        if not sockets:
            return
        sockets.discard(websocket)
        if not sockets:
            self._connections.pop(user_id, None)

    async def send_to_user(self, user_id: int, event: dict) -> None:
        for ws in list(self._connections.get(user_id, ())):
            try:
                await ws.send_json(event)
            except (WebSocketDisconnect, RuntimeError):
                # Socket already closed on the other end — drop our record
                # of it. Any other exception (e.g. a bad payload) is a bug
                # to surface, not a reason to forget a live connection.
                self.disconnect(user_id, ws)

    async def broadcast_to_conversation(
        self,
        conversation: Conversation,
        event: dict,
        exclude_user_id: Optional[int] = None,
    ) -> None:
        for participant in conversation.participants:
            if participant.left_at is not None:
                continue
            if exclude_user_id is not None and participant.user_id == exclude_user_id:
                continue
            await self.send_to_user(participant.user_id, event)


manager = ConnectionManager()


def _authenticate(token: str) -> Optional[int]:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return int(payload.get("sub"))
    except (JWTError, ValueError, TypeError):
        return None


@router.websocket("/ws/chat")
async def chat_socket(websocket: WebSocket, token: str = Query(...)) -> None:
    user_id = _authenticate(token)
    if user_id is None:
        await websocket.close(code=4401)
        return

    db = SessionLocal()
    try:
        user_exists = db.query(User.id).filter(User.id == user_id).first() is not None
    finally:
        db.close()
    if not user_exists:
        await websocket.close(code=4401)
        return

    await manager.connect(user_id, websocket)
    try:
        while True:
            raw = await websocket.receive_text()
            try:
                data = json.loads(raw)
            except ValueError:
                continue
            await _handle_incoming(user_id, data)
    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect(user_id, websocket)


async def _handle_incoming(sender_id: int, data: dict) -> None:
    event_type = data.get("type")
    if event_type == "ping":
        await manager.send_to_user(sender_id, {"type": "pong"})
        return
    if event_type not in _CALL_AND_PRESENCE_EVENTS or data.get("conversation_id") is None:
        return
    try:
        # The Flutter client sends conversation_id as a string (it's typed
        # `String` throughout the chat module); the column is Integer, so
        # this must be cast or the lookup below silently matches nothing —
        # which used to make every client-initiated signaling message
        # (call:invite/ready/offer/answer/ice/leave/end) a silent no-op.
        conversation_id = int(data["conversation_id"])
    except (TypeError, ValueError):
        return

    db: Session = SessionLocal()
    try:
        conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
        if not conversation:
            return
        sender_is_participant = any(
            p.user_id == sender_id and p.left_at is None for p in conversation.participants
        )
        if not sender_is_participant:
            return

        event = dict(data)
        event["from_user_id"] = str(sender_id)

        if event_type == "call:end" and data.get("outcome"):
            # Deferred import: app.api.chat imports this module, so importing
            # it back at module load time would be circular.
            from app.api.chat import serialize_message

            message = Message(
                conversation_id=conversation_id,
                sender_id=sender_id,
                type="call_log",
                call_is_video=bool(data.get("is_video")),
                call_outcome=data.get("outcome"),
                call_duration_seconds=int(data.get("duration_seconds") or 0),
            )
            db.add(message)
            for participant in conversation.participants:
                participant.hidden_at = None
            db.commit()
            db.refresh(message)
            event["message"] = serialize_message(db, conversation, message)

        to_user_id = data.get("to_user_id")
        target_ids = (
            [int(to_user_id)]
            if to_user_id is not None
            else [
                p.user_id
                for p in conversation.participants
                if p.left_at is None and p.user_id != sender_id
            ]
        )
        for uid in target_ids:
            await manager.send_to_user(uid, event)
    finally:
        db.close()
