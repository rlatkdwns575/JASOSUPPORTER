"""Pinecone 벡터 저장/검색 서비스.

- 네임스페이스 = user_id
- 키가 없으면 모든 연산이 안전하게 no-op 이 되고, RAG 는 로컬 저장소 폴백을 사용한다.
"""

from typing import Optional

from ..config import get_settings
from ..logging_config import get_logger

logger = get_logger(__name__)

_pc = None
_index = None
_init_failed = False
_dimension_mismatch = False


def is_enabled() -> bool:
    return get_settings().pinecone_enabled and not _init_failed


def dimension_mismatch() -> bool:
    return _dimension_mismatch


def _read_index_dimension(pc: object, index_name: str) -> int | None:
    try:
        description = pc.describe_index(index_name)
    except Exception:
        logger.exception("pinecone describe_index failed index=%s", index_name)
        return None
    dimension = getattr(description, "dimension", None)
    if dimension is None and isinstance(description, dict):
        dimension = description.get("dimension")
    return int(dimension) if dimension is not None else None


def _validate_index_dimension(pc: object, index_name: str, expected: int) -> bool:
    actual = _read_index_dimension(pc, index_name)
    if actual is None:
        return True
    if actual == expected:
        return True
    global _dimension_mismatch
    _dimension_mismatch = True
    logger.error(
        "pinecone index dimension mismatch index=%s got=%s expected=%s; "
        "set EMBEDDING_DIMENSION to match the index or recreate the index",
        index_name,
        actual,
        expected,
    )
    return False


def _get_index():
    """인덱스 핸들을 반환한다. 필요 시 인덱스를 생성한다. 실패하면 None."""
    global _pc, _index, _init_failed, _dimension_mismatch
    if _init_failed:
        return None
    if _index is not None:
        return _index

    settings = get_settings()
    if not settings.pinecone_enabled:
        logger.info("pinecone disabled: PINECONE_API_KEY not set")
        _init_failed = True
        return None

    try:
        from pinecone import Pinecone, ServerlessSpec

        _pc = Pinecone(api_key=settings.pinecone_api_key)
        existing = set(_pc.list_indexes().names())
        if settings.pinecone_index not in existing:
            logger.info("creating pinecone index=%s", settings.pinecone_index)
            _pc.create_index(
                name=settings.pinecone_index,
                dimension=settings.embedding_dimension,
                metric="cosine",
                spec=ServerlessSpec(
                    cloud=settings.pinecone_cloud,
                    region=settings.pinecone_region,
                ),
            )
        elif not _validate_index_dimension(
            _pc,
            settings.pinecone_index,
            settings.embedding_dimension,
        ):
            _init_failed = True
            return None
        _index = _pc.Index(settings.pinecone_index)
        logger.info("pinecone index ready=%s", settings.pinecone_index)
        return _index
    except Exception:
        logger.exception("pinecone init failed index=%s", settings.pinecone_index)
        _init_failed = True
        return None


def upsert_experience(user_id: str, experience_id: str, values: list[float], metadata: dict) -> bool:
    index = _get_index()
    if index is None:
        return False
    try:
        index.upsert(
            vectors=[{"id": experience_id, "values": values, "metadata": metadata}],
            namespace=user_id,
        )
        return True
    except Exception:
        logger.exception(
            "pinecone upsert failed user_id=%s experience_id=%s",
            user_id,
            experience_id,
        )
        return False


def query_experiences(user_id: str, values: list[float], top_k: int) -> list[dict]:
    """유사도 상위 top_k 경험의 metadata 리스트를 반환한다."""
    index = _get_index()
    if index is None:
        return []
    try:
        response = index.query(
            vector=values,
            top_k=top_k,
            namespace=user_id,
            include_metadata=True,
        )
    except Exception:
        logger.exception("pinecone query failed user_id=%s top_k=%s", user_id, top_k)
        return []
    matches = response.get("matches") if isinstance(response, dict) else getattr(response, "matches", None)
    result: list[dict] = []
    for match in matches or []:
        metadata = match.get("metadata") if isinstance(match, dict) else getattr(match, "metadata", None)
        score = match.get("score") if isinstance(match, dict) else getattr(match, "score", None)
        if metadata:
            item = dict(metadata)
            if score is not None:
                item["_score"] = score
            result.append(item)
    return result


def delete_experience(user_id: str, experience_id: str) -> bool:
    index = _get_index()
    if index is None:
        return False
    try:
        index.delete(ids=[experience_id], namespace=user_id)
        return True
    except Exception:
        logger.exception(
            "pinecone delete failed user_id=%s experience_id=%s",
            user_id,
            experience_id,
        )
        return False
