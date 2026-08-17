"""RAG rerank 유틸 테스트."""

from app.services.rag import _rerank_metadata, _tokenize


def test_tokenize_splits_words() -> None:
    tokens = _tokenize("백엔드 FastAPI 역할")
    assert "fastapi" in tokens
    assert "역할" in tokens


def test_rerank_metadata_boosts_keyword_overlap() -> None:
    matches = [
        {"_score": 0.9, "title": "동아리", "role": "회원"},
        {"_score": 0.85, "title": "인턴", "role": "백엔드", "skills": "FastAPI"},
    ]
    ranked = _rerank_metadata("백엔드 FastAPI", matches)
    assert ranked[0]["title"] == "인턴"


def test_rerank_metadata_keeps_order_when_no_query_tokens() -> None:
    matches = [{"_score": 0.5, "title": "a"}, {"_score": 0.4, "title": "b"}]
    assert _rerank_metadata("", matches) == matches
