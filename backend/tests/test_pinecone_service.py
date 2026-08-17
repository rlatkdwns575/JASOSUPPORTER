"""Pinecone 차원 검증 테스트."""

from unittest.mock import MagicMock

from app.services import pinecone_service


def _reset_pinecone_state() -> None:
    pinecone_service._pc = None
    pinecone_service._index = None
    pinecone_service._init_failed = False
    pinecone_service._dimension_mismatch = False


def test_validate_index_dimension_accepts_matching_dimension() -> None:
    _reset_pinecone_state()
    pc = MagicMock()
    pc.describe_index.return_value = MagicMock(dimension=512)

    assert pinecone_service._validate_index_dimension(pc, "jaso-supporter", 512) is True
    assert pinecone_service.dimension_mismatch() is False


def test_validate_index_dimension_flags_mismatch() -> None:
    _reset_pinecone_state()
    pc = MagicMock()
    pc.describe_index.return_value = MagicMock(dimension=768)

    assert pinecone_service._validate_index_dimension(pc, "jaso-supporter", 512) is False
    assert pinecone_service.dimension_mismatch() is True
