"""애플리케이션 설정. 비밀 키는 .env 에서만 로드한다."""

from functools import lru_cache
from typing import ClassVar

from pydantic_settings import BaseSettings, SettingsConfigDict

DEFAULT_JWT_SECRET = "dev-change-me-jaso-supporter"


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # LLM — 로컬 Ollama 전용
    llm_provider: str = "ollama"
    ollama_base_url: str = "http://127.0.0.1:11435"
    ollama_model: str = "jaso-coach"
    ollama_allowed_models: str = "jaso-coach,qwen3:1.7b"
    ollama_timeout_sec: int = 300

    # App
    default_user_id: str = "default"
    database_url: str = "sqlite:///./jaso_supporter.db"
    cors_origins: str = "*"
    # 선택 경험이 없을 때 최근 Experience 폴백 개수
    rag_top_k: int = 5
    log_level: str = "INFO"

    jwt_secret: str = "dev-change-me-jaso-supporter"
    jwt_algorithm: str = "HS256"
    jwt_expire_minutes: int = 60 * 24 * 7
    auth_required: bool = False

    DEFAULT_JWT_SECRET: ClassVar[str] = DEFAULT_JWT_SECRET

    @property
    def jwt_secret_is_default(self) -> bool:
        secret = self.jwt_secret.strip()
        return not secret or secret == DEFAULT_JWT_SECRET or len(secret) < 16

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def ollama_enabled(self) -> bool:
        return True

    @property
    def allowed_ollama_models(self) -> list[str]:
        models = [
            item.strip()
            for item in self.ollama_allowed_models.split(",")
            if item.strip()
        ]
        default = self.ollama_model.strip()
        if default and default not in models:
            models.insert(0, default)
        return models

    def resolve_ollama_model(self, requested: str | None) -> str:
        candidate = (requested or "").strip()
        allowed = self.allowed_ollama_models
        if candidate and candidate in allowed:
            return candidate
        return self.ollama_model

    @property
    def active_llm_provider(self) -> str:
        return "ollama"


@lru_cache
def get_settings() -> Settings:
    return Settings()
