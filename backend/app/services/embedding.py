"""Gemini 임베딩 서비스 (text-embedding-004, 768차원)."""

from typing import Optional

import google.generativeai as genai

from ..config import get_settings
from ..logging_config import get_logger

logger = get_logger(__name__)

_configured = False


def _ensure_configured() -> bool:
    global _configured
    settings = get_settings()
    if not settings.gemini_enabled:
        logger.warning("embedding skipped: GOOGLE_API_KEY not configured")
        return False
    if not _configured:
        genai.configure(api_key=settings.google_api_key)
        _configured = True
    return True


def embed_text(text: str, *, is_query: bool = False) -> Optional[list[float]]:
    """텍스트를 임베딩 벡터로 변환한다. 키가 없거나 빈 텍스트면 None."""
    if not text or not text.strip():
        return None
    if not _ensure_configured():
        return None
    settings = get_settings()
    task_type = "retrieval_query" if is_query else "retrieval_document"
    try:
        result = genai.embed_content(
            model=settings.embedding_model,
            content=text,
            task_type=task_type,
        )
    except Exception:
        logger.exception(
            "embedding failed model=%s is_query=%s text_len=%s",
            settings.embedding_model,
            is_query,
            len(text),
        )
        return None
    embedding = result.get("embedding") if isinstance(result, dict) else None
    if embedding is None:
        logger.error("embedding response missing 'embedding' field")
        return None
    return list(embedding)
