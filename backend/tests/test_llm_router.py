"""LLM provider 라우터 테스트."""

from app.services.llm.router import get_llm_provider, resolve_provider_for_request


def test_get_llm_provider_ollama(monkeypatch) -> None:
    monkeypatch.setenv("LLM_PROVIDER", "ollama")
    from app.config import get_settings

    get_settings.cache_clear()
    provider = get_llm_provider()
    assert provider.provider_id == "ollama"
    get_settings.cache_clear()


def test_attachment_falls_back_to_gemini_when_cloud_enabled(monkeypatch) -> None:
    monkeypatch.setenv("LLM_PROVIDER", "ollama")
    monkeypatch.setenv("CLOUD_AI_ENABLED", "true")
    monkeypatch.setenv("GOOGLE_API_KEY", "test-key")
    from app.config import get_settings

    get_settings.cache_clear()
    provider = resolve_provider_for_request(
        attachments=[{"data": b"x", "mime_type": "image/png"}],
    )
    assert provider.provider_id == "gemini"
    get_settings.cache_clear()


def test_attachment_stays_ollama_when_cloud_disabled(monkeypatch) -> None:
    monkeypatch.setenv("LLM_PROVIDER", "ollama")
    monkeypatch.setenv("CLOUD_AI_ENABLED", "false")
    from app.config import get_settings

    get_settings.cache_clear()
    provider = resolve_provider_for_request(
        attachments=[{"data": b"x", "mime_type": "image/png"}],
    )
    assert provider.provider_id == "ollama"
    get_settings.cache_clear()
