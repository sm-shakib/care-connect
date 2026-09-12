import base64
import hashlib
import os
from pathlib import Path
from dotenv import load_dotenv

# Find the .env file in the backend root, even if started from elsewhere
env_path = Path(__file__).resolve().parent.parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

class Settings:
    PROJECT_NAME: str = "Care Connect"
    DATABASE_URL: str = os.getenv("DATABASE_URL")

    # JWT Security Settings
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-super-secret-key-change-this-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 1 week

    # Email Settings
    SMTP_USER: str = os.getenv("SMTP_USER")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD")
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.gmail.com")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", "587"))
    FROM_EMAIL: str = os.getenv("FROM_EMAIL")


    CHAT_MASTER_KEY: str = os.getenv("CHAT_MASTER_KEY") or base64.b64encode(
        hashlib.sha256(f"chat-master-key:{SECRET_KEY}".encode()).digest()
    ).decode()

    STUN_URLS: list = [
        url.strip()
        for url in os.getenv("STUN_URLS", "stun:stun.l.google.com:19302").split(",")
        if url.strip()
    ]
    TURN_URLS: list = [
        url.strip() for url in os.getenv("TURN_URLS", "").split(",") if url.strip()
    ]
    # A hosted relay's long-lived pair, straight from its dashboard.
    TURN_USERNAME: str = os.getenv("TURN_USERNAME", "")
    TURN_PASSWORD: str = os.getenv("TURN_PASSWORD", "")
    # Self-hosted coturn in `use-auth-secret` mode. Takes precedence over
    # the static pair above, since per-user expiring credentials are
    # strictly safer than one shared secret that never rotates.
    TURN_STATIC_AUTH_SECRET: str = os.getenv("TURN_STATIC_AUTH_SECRET", "")
    TURN_CREDENTIAL_TTL: int = int(os.getenv("TURN_CREDENTIAL_TTL", str(60 * 60 * 12)))

    # bKash Settings
    BKASH_USERNAME: str = os.getenv("BKASH_USERNAME")
    BKASH_PASSWORD: str = os.getenv("BKASH_PASSWORD")
    BKASH_APP_KEY: str = os.getenv("BKASH_APP_KEY")
    BKASH_APP_SECRET: str = os.getenv("BKASH_APP_SECRET")
    BKASH_BASE_URL: str = os.getenv("BKASH_BASE_URL", "https://tokenized.sandbox.bka.sh/v1.2.0-beta")

settings = Settings()
