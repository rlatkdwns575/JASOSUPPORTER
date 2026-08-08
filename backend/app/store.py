"""문서 저장소 CRUD 헬퍼. Flutter 도메인 모델과 동일한 camelCase JSON dict 를 그대로 보관한다."""

import json
from datetime import datetime, timezone
from typing import Optional

from sqlmodel import Session, select

from .db import CareerDocument, engine

# 지원하는 컬렉션(kind) 목록.
KIND_EXPERIENCE = "experience"
KIND_SPEC_ITEM = "specItem"
KIND_MASTER_ESSAY = "masterEssay"
KIND_ESSAY_VERSION = "essayVersion"
KIND_PORTFOLIO = "portfolioProject"
KIND_APPLICATION = "applicationRecord"
KIND_INTERVIEW_ANSWER = "interviewAnswer"


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def upsert(kind: str, user_id: str, doc_id: str, data: dict) -> dict:
    updated_at = str(data.get("updatedAt") or _now_iso())
    payload = json.dumps(data, ensure_ascii=False)
    with Session(engine) as session:
        statement = select(CareerDocument).where(
            CareerDocument.kind == kind,
            CareerDocument.user_id == user_id,
            CareerDocument.doc_id == doc_id,
        )
        existing = session.exec(statement).first()
        if existing is not None:
            existing.data = payload
            existing.updated_at = updated_at
            session.add(existing)
        else:
            session.add(
                CareerDocument(
                    user_id=user_id,
                    kind=kind,
                    doc_id=doc_id,
                    data=payload,
                    updated_at=updated_at,
                )
            )
        session.commit()
    return data


def list_docs(kind: str, user_id: str) -> list[dict]:
    with Session(engine) as session:
        statement = select(CareerDocument).where(
            CareerDocument.kind == kind,
            CareerDocument.user_id == user_id,
        )
        rows = session.exec(statement).all()
    return [json.loads(row.data) for row in rows]


def get_doc(kind: str, user_id: str, doc_id: str) -> Optional[dict]:
    with Session(engine) as session:
        statement = select(CareerDocument).where(
            CareerDocument.kind == kind,
            CareerDocument.user_id == user_id,
            CareerDocument.doc_id == doc_id,
        )
        row = session.exec(statement).first()
    if row is None:
        return None
    return json.loads(row.data)


def get_many(kind: str, user_id: str, doc_ids: list[str]) -> list[dict]:
    if not doc_ids:
        return []
    wanted = set(doc_ids)
    return [doc for doc in list_docs(kind, user_id) if str(doc.get("id")) in wanted]


def delete_doc(kind: str, user_id: str, doc_id: str) -> None:
    with Session(engine) as session:
        statement = select(CareerDocument).where(
            CareerDocument.kind == kind,
            CareerDocument.user_id == user_id,
            CareerDocument.doc_id == doc_id,
        )
        row = session.exec(statement).first()
        if row is not None:
            session.delete(row)
            session.commit()
