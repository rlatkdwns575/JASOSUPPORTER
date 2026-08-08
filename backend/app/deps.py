"""공용 의존성. JWT Bearer 우선, 개발용 soft X-User-Id 폴백."""

from typing import Optional

from fastapi import Header, HTTPException, Query

from .config import get_settings
from .services import auth_service


def get_user_id(
    authorization: Optional[str] = Header(default=None),
    user_id_q: Optional[str] = Query(default=None, alias="userId"),
    user_id_h: Optional[str] = Header(default=None, alias="X-User-Id"),
) -> str:
    settings = get_settings()

    if authorization and authorization.lower().startswith("bearer "):
        token = authorization.split(" ", 1)[1].strip()
        payload = auth_service.decode_token(token)
        if payload is None or not str(payload.get("sub") or "").strip():
            raise HTTPException(status_code=401, detail="Invalid or expired token")
        return str(payload["sub"])

    if settings.auth_required:
        raise HTTPException(status_code=401, detail="Authorization Bearer token required")

    candidate = (user_id_q or user_id_h or "").strip()
    return candidate or settings.default_user_id
