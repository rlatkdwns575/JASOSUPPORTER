"""embedding 서비스 유틸 테스트."""

from google.genai import types

from app.services.embedding import _build_embed_config, _map_task_type, _model_candidates


def test_model_candidates_adds_bare_and_prefixed_variants():
    assert _model_candidates("text-embedding-004") == [
        "text-embedding-004",
        "models/text-embedding-004",
        "gemini-embedding-001",
        "embedding-001",
    ]


def test_model_candidates_strips_duplicate_prefix():
    assert _model_candidates("models/text-embedding-004")[0] == "text-embedding-004"
    assert "models/text-embedding-004" in _model_candidates("models/text-embedding-004")


def test_map_task_type_normalizes_legacy_values():
    assert _map_task_type("retrieval_document") == "RETRIEVAL_DOCUMENT"
    assert _map_task_type("RETRIEVAL_QUERY") == "RETRIEVAL_QUERY"


def test_build_embed_config_adds_output_dimensionality_for_004():
    config = _build_embed_config(
        task_type="retrieval_document",
        output_dim=512,
        model="text-embedding-004",
    )
    assert isinstance(config, types.EmbedContentConfig)
    assert config.task_type == "RETRIEVAL_DOCUMENT"
    assert config.output_dimensionality == 512


def test_build_embed_config_skips_output_dimensionality_for_001():
    config = _build_embed_config(
        task_type="retrieval_document",
        output_dim=512,
        model="gemini-embedding-001",
    )
    assert isinstance(config, types.EmbedContentConfig)
    assert config.output_dimensionality is None
