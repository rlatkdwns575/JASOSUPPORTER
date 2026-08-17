"""Experience CRUD + 저장 시 Pinecone upsert(임베딩)."""

from fastapi import APIRouter, Depends, HTTPException

from ..config import get_settings
from .. import store
from ..deps import get_user_id
from ..logging_config import get_logger
from ..models import Experience
from ..services import embedding, pinecone_service

logger = get_logger(__name__)

router = APIRouter(prefix="/experiences", tags=["experiences"])


def _index_experience(user_id: str, exp: Experience) -> None:
    """경험을 임베딩해 Pinecone 에 upsert. 키가 없으면 건너뛴다(로그 남김)."""
    text = exp.embedding_text()
    if not text:
        logger.info("skip index: empty embedding text id=%s", exp.id)
        return
    vector = embedding.embed_text(text, is_query=False)
    if vector is None:
        logger.warning("skip index: embedding unavailable id=%s user_id=%s", exp.id, user_id)
        return
    # P2: retrieval 품질을 위한 메타데이터 강화
    metadata = {
        "experience_id": exp.id,
        "title": exp.title,
        "type": exp.type,
        "role": (exp.role or "")[:200],
        "organization": (exp.organization or "")[:200],
        "result": (exp.result or "")[:500],
        "skills": ",".join((exp.tech_stacks or [])[:20]),
        "competencies": ",".join((exp.competency_tags or [])[:20]),
        "text": text[:8000],
    }
    ok = pinecone_service.upsert_experience(user_id, exp.id, vector, metadata)
    if not ok:
        logger.warning("pinecone upsert returned false id=%s user_id=%s", exp.id, user_id)
    elif len(vector) != get_settings().embedding_dimension:
        logger.warning(
            "vector length %s does not match EMBEDDING_DIMENSION=%s for id=%s",
            len(vector),
            get_settings().embedding_dimension,
            exp.id,
        )


@router.get("")
def list_experiences(user_id: str = Depends(get_user_id)) -> list[dict]:
    return store.list_docs(store.KIND_EXPERIENCE, user_id)


@router.get("/{experience_id}")
def get_experience(experience_id: str, user_id: str = Depends(get_user_id)) -> dict:
    doc = store.get_doc(store.KIND_EXPERIENCE, user_id, experience_id)
    if doc is None:
        raise HTTPException(status_code=404, detail="Experience not found")
    return doc


@router.post("")
def save_experience(payload: Experience, user_id: str = Depends(get_user_id)) -> dict:
    if not payload.id.strip():
        raise HTTPException(status_code=400, detail="Experience id is required")
    data = payload.model_dump(by_alias=True)
    store.upsert(store.KIND_EXPERIENCE, user_id, payload.id, data)
    _index_experience(user_id, payload)
    return data


@router.delete("/{experience_id}")
def delete_experience(experience_id: str, user_id: str = Depends(get_user_id)) -> dict:
    store.delete_doc(store.KIND_EXPERIENCE, user_id, experience_id)
    pinecone_service.delete_experience(user_id, experience_id)
    return {"ok": True}
