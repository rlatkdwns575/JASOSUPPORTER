"""LLM provider 라우터 테스트 — Ollama only."""

from app.services.llm.router import get_llm_provider, resolve_provider_for_request


def test_get_llm_provider_ollama() -> None:
    provider = get_llm_provider()
    assert provider.provider_id == "ollama"


def test_attachments_still_use_ollama() -> None:
    provider = resolve_provider_for_request(
        attachments=[{"data": b"x", "mime_type": "image/png"}],
    )
    assert provider.provider_id == "ollama"
