from pydantic import BaseModel
from typing import Optional

class Token(BaseModel):
    access_token: str
    token_type: str
    role: str
    status: Optional[str] = None

class TokenPayload(BaseModel):
    sub: Optional[int] = None