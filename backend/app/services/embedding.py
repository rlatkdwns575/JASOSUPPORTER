"""Gemini 임베딩 서비스 (환경 변수 차원 설정 반영)."""

from typing import Optional

from google.genai import errors as genai_errors
from google.genai import types

from ..config import get_settings
from ..logging_config import get_logger
from .gemini_client import get_genai_client

logger = get_logger(__name__)

_TASK_TYPE_MAP = {
    "retrieval_query": "RETRIEVAL_QUERY",
    "retrieval_document": "RETRIEVAL_DOCUMENT",
    "semantic_similarity": "SEMANTIC_SIMILARITY",
    "classification": "CLASSIFICATION",
    "clustering": "CLUSTERING",
    "question_answering": "QUESTION_ANSWERING",
    "fact_verification": "FACT_VERIFICATION",
}


def _model_candidates(model: str) -> list[str]:
    trimmed = model.strip()
    if not trimmed:
        return []
    bare = trimmed.removeprefix("models/")
    candidates = [bare]
    prefixed = trimmed if trimmed.startswith("models/") else f"models/{bare}"
    if prefixed not in candidates:
        candidates.append(prefixed)
    if "text-embedding-004" in trimmed:
        candidates.extend(
            [
                "gemini-embedding-001",
                "embedding-001",
            ]
        )
    return list(dict.fromkeys(candidates))


def _map_task_type(task_type: str) -> str | None:
    normalized = task_type.strip().lower()
    if normalized in _TASK_TYPE_MAP:
        return _TASK_TYPE_MAP[normalized]
    upper = task_type.strip().upper()
    if upper in _TASK_TYPE_MAP.values():
        return upper
    return None


def _build_embed_config(
    *,
    task_type: str,
    output_dim: int,
    model: str,
) -> types.EmbedContentConfig | None:
    config_kwargs: dict = {}
    mapped_task = _map_task_type(task_type)
    if mapped_task:
        config_kwargs["task_type"] = mapped_task
    # text-embedding-004 는 차원 축소를 지원하므로 .env EMBEDDING_DIMENSION 을 직접 반영한다.
    if output_dim > 0 and "text-embedding-004" in model:
        config_kwargs["output_dimensionality"] = output_dim
    if not config_kwargs:
        return None
    return types.EmbedContentConfig(**config_kwargs)


def _extract_embedding_values(response: object) -> list[float] | None:
    embeddings = getattr(response, "embeddings", None)
    if not embeddings:
        return None
    values = getattr(embeddings[0], "values", None)
    if values is None:
        return None
    return list(values)


def embed_text(text: str, *, is_query: bool = False) -> Optional[list[float]]:
    """텍스트를 임베딩 벡터로 변환한다. 키가 없거나 빈 텍스트면 None."""
    if not text or not text.strip():
        return None

    client = get_genai_client()
    if client is None:
        logger.warning("embedding skipped: GOOGLE_API_KEY not configured")
        return None

    settings = get_settings()
    task_type = "retrieval_query" if is_query else "retrieval_document"

    last_error: Exception | None = None
    for model in _model_candidates(settings.embedding_model):
        config = _build_embed_config(
            task_type=task_type,
            output_dim=settings.embedding_dimension,
            model=model,
        )
        try:
            response = client.models.embed_content(
                model=model,
                contents=text,
                config=config,
            )
        except genai_errors.ClientError as exc:
            if exc.code == 404:
                logger.warning("embedding model not found, trying fallback: %s", model)
                last_error = exc
                continue
            logger.exception(
                "embedding client error model=%s is_query=%s text_len=%s code=%s",
                model,
                is_query,
                len(text),
                exc.code,
            )
            return None
        except Exception:
            logger.exception(
                "embedding failed model=%s is_query=%s text_len=%s",
                model,
                is_query,
                len(text),
            )
            return None

        vector = _extract_embedding_values(response)
        if vector is None:
            logger.error("embedding response missing values model=%s", model)
            return None

        expected = settings.embedding_dimension
        if expected and len(vector) != expected:
            logger.warning(
                "embedding dimension mismatch model=%s got=%s expected=%s",
                model,
                len(vector),
                expected,
            )
        return vector

    if last_error is not None:
        logger.error("all embedding model candidates failed: %s", last_error)
    return None
