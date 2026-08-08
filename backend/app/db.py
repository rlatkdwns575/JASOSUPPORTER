"""SQLModel 기반 저장소.

- CareerDocument: 커리어 JSON 문서
- AuthUser: 이메일/비밀번호 계정
"""

from typing import Optional

from sqlmodel import Field, SQLModel, create_engine

from .config import get_settings


class CareerDocument(SQLModel, table=True):
    __tablename__ = "career_documents"

    pk: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True)
    kind: str = Field(index=True)
    doc_id: str = Field(index=True)
    data: str = ""
    updated_at: str = ""


class AuthUser(SQLModel, table=True):
    __tablename__ = "auth_users"

    id: str = Field(primary_key=True)
    email: str = Field(index=True, unique=True)
    password_hash: str = ""
    created_at: str = ""


_settings = get_settings()
_connect_args = {"check_same_thread": False} if _settings.database_url.startswith("sqlite") else {}
engine = create_engine(_settings.database_url, echo=False, connect_args=_connect_args)


def init_db() -> None:
    SQLModel.metadata.create_all(engine)
