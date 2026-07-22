"""공용 의존성. 단일 사용자 기준이지만 user_id 네임스페이스를 처음부터 사용한다."""

from typing import Optional

from fastapi import Header, Query

from .config import get_settings


def get_user_id(
    user_id_q: Optional[str] = Query(default=None, alias="userId"),
    user_id_h: Optional[str] = Header(default=None, alias="X-User-Id"),
) -> str:
    candidate = (user_id_q or user_id_h or "").strip()
    return candidate or get_settings().default_user_id
