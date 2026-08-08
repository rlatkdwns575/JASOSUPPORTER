"""JWT + 비밀번호 해시 인증."""

from __future__ import annotations

import uuid
from datetime import datetime, timedelta, timezone
from typing import Optional

import bcrypt
from jose import JWTError, jwt
from sqlmodel import Session, select

from ..config import get_settings
from ..db import AuthUser, engine
from ..logging_config import get_logger

logger = get_logger(__name__)


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except Exception:
        logger.exception("password verify failed")
        return False


def create_access_token(*, user_id: str, email: str) -> str:
    settings = get_settings()
    expire = datetime.now(timezone.utc) + timedelta(minutes=settings.jwt_expire_minutes)
    payload = {
        "sub": user_id,
        "email": email,
        "exp": expire,
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)


def decode_token(token: str) -> Optional[dict]:
    settings = get_settings()
    try:
        return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    except JWTError:
        logger.info("invalid JWT")
        return None


def get_user_by_email(email: str) -> Optional[AuthUser]:
    with Session(engine) as session:
        return session.exec(select(AuthUser).where(AuthUser.email == email.lower().strip())).first()


def get_user_by_id(user_id: str) -> Optional[AuthUser]:
    with Session(engine) as session:
        return session.get(AuthUser, user_id)


def register_user(email: str, password: str) -> AuthUser:
    normalized = email.lower().strip()
    if not normalized or "@" not in normalized:
        raise ValueError("유효한 이메일이 필요합니다.")
    if len(password) < 8:
        raise ValueError("비밀번호는 8자 이상이어야 합니다.")
    if get_user_by_email(normalized) is not None:
        raise ValueError("이미 등록된 이메일입니다.")
    user = AuthUser(
        id=str(uuid.uuid4()),
        email=normalized,
        password_hash=hash_password(password),
        created_at=datetime.now(timezone.utc).isoformat(),
    )
    with Session(engine) as session:
        session.add(user)
        session.commit()
        session.refresh(user)
        return user


def authenticate(email: str, password: str) -> Optional[AuthUser]:
    user = get_user_by_email(email)
    if user is None:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user
