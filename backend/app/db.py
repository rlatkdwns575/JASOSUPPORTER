"""SQLite(SQLModel) 기반 문서 저장소.

Experience 등 커리어 엔티티는 리스트/중첩 필드가 많아, 엔티티별 테이블 대신
(kind, user_id, doc_id) 로 식별되는 JSON 문서 테이블로 저장한다. 이는 유연한
스키마 변경을 허용하면서도 목록/단건 조회/삭제를 안정적으로 지원한다.
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


_settings = get_settings()
_connect_args = {"check_same_thread": False} if _settings.database_url.startswith("sqlite") else {}
engine = create_engine(_settings.database_url, echo=False, connect_args=_connect_args)


def init_db() -> None:
    SQLModel.metadata.create_all(engine)
