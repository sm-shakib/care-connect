"""ICE servers handed to the client before it opens a peer connection —
see `GET /chat/ice-servers` and `CallCubit` on the Flutter side.

A STUN server is enough for a device to discover its own public address,
but not to get media through symmetric or carrier-grade NAT, which is what
most mobile networks put their subscribers behind. Those calls only ever
connect through a TURN relay, so call setup needs credentials for one.

Two credential styles are supported, because they are the two this project
actually uses:

- **Static** (`TURN_USERNAME` / `TURN_PASSWORD`) — a hosted relay whose
  dashboard issues one long-lived pair.
- **Ephemeral** (`TURN_STATIC_AUTH_SECRET`) — coturn's `use-auth-secret`
  mode, where the relay and this API share one secret and every client
  gets a short-lived pair derived from it. Preferred wherever it's
  available, so it wins if both are configured.

Either way the credentials are minted here, server-side, and handed out
over an authenticated request — nothing long-lived is ever compiled into
the app, where anyone with the APK could read it and spend the relay
bandwidth this project is paying for.
"""
import base64
import hashlib
import hmac
import time
from typing import List, Optional, Tuple

from app.core.config import settings


def _ephemeral_credentials(user_id: int) -> Tuple[str, str]:
    """Mint a time-limited pair for coturn's `use-auth-secret` mode.

    The username *is* its own expiry stamp and the password is an HMAC of
    it, so the relay can validate the pair against the shared secret alone
    — it never needs a user database, and a leaked pair stops working on
    its own after `TURN_CREDENTIAL_TTL`.
    """
    expires_at = int(time.time()) + settings.TURN_CREDENTIAL_TTL
    username = f"{expires_at}:{user_id}"
    digest = hmac.new(
        settings.TURN_STATIC_AUTH_SECRET.encode(),
        username.encode(),
        hashlib.sha1,
    ).digest()
    return username, base64.b64encode(digest).decode()


def _turn_credentials(user_id: int) -> Optional[Tuple[str, str]]:
    if settings.TURN_STATIC_AUTH_SECRET:
        return _ephemeral_credentials(user_id)
    if settings.TURN_USERNAME and settings.TURN_PASSWORD:
        return settings.TURN_USERNAME, settings.TURN_PASSWORD
    return None


def build_ice_servers(user_id: int) -> List[dict]:
    """The ICE server list for one call, in the shape WebRTC expects.

    One entry per URL rather than one entry with a list of URLs: it is the
    shape every relay provider's own dashboard shows, which keeps a
    misconfigured URL obvious when comparing the two.

    A deployment with no TURN configured still gets STUN back, and calls
    still connect wherever the two NATs allow a direct path — degraded,
    not broken.
    """
    servers: List[dict] = [{"urls": url} for url in settings.STUN_URLS]
    credentials = _turn_credentials(user_id)
    if credentials is None:
        return servers

    username, credential = credentials
    servers.extend(
        {"urls": url, "username": username, "credential": credential}
        for url in settings.TURN_URLS
    )
    return servers
