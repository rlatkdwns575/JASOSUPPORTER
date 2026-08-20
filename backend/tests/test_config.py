"""설정·보안 플래그 테스트."""

from app.config import DEFAULT_JWT_SECRET, Settings


def test_jwt_secret_is_default_detects_placeholder() -> None:
    settings = Settings(jwt_secret=DEFAULT_JWT_SECRET)
    assert settings.jwt_secret_is_default is True


def test_jwt_secret_is_default_accepts_long_custom_secret() -> None:
    settings = Settings(jwt_secret="this-is-a-long-production-secret-value")
    assert settings.jwt_secret_is_default is False


def test_active_llm_provider_defaults_to_gemini() -> None:
    settings = Settings()
    assert settings.active_llm_provider == "gemini"


def test_ollama_model_resolution() -> None:
    settings = Settings(
        llm_provider="ollama",
        ollama_model="jaso-coach",
        ollama_allowed_models="jaso-coach,qwen2.5:7b-instruct",
    )
    assert settings.resolve_ollama_model("qwen2.5:7b-instruct") == "qwen2.5:7b-instruct"
    assert settings.resolve_ollama_model("unknown") == "jaso-coach"
    assert "jaso-coach" in settings.allowed_ollama_models


def test_cloud_ai_enabled_default() -> None:
    settings = Settings(cloud_ai_enabled=False)
    assert settings.cloud_ai_enabled is False
