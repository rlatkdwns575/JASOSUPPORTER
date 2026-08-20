"""애플리케이션 설정. 모든 비밀 키는 이 계층(.env)에서만 로드된다."""

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

    # LLM provider
    llm_provider: str = "gemini"  # gemini | ollama
    cloud_ai_enabled: bool = True
    ollama_base_url: str = "http://127.0.0.1:11434"
    ollama_model: str = "jaso-coach"
    ollama_allowed_models: str = "jaso-coach,qwen2.5:7b-instruct"
    ollama_timeout_sec: int = 120

    # Gemini
    google_api_key: str = ""
    gemini_model: str = "gemini-2.5-flash"
    # 클라이언트가 고를 수 있는 모델 (콤마 구분). 기본 모델은 항상 포함된다.
    gemini_allowed_models: str = (
        "gemini-3.6-flash,gemini-2.5-flash,gemini-2.5-pro,"
        "gemini-2.0-flash,gemini-1.5-flash,gemini-1.5-pro"
    )
    embedding_model: str = "models/text-embedding-004"
    embedding_dimension: int = 768

    # Pinecone
    pinecone_api_key: str = ""
    pinecone_index: str = "jaso-supporter"
    pinecone_cloud: str = "aws"
    pinecone_region: str = "us-east-1"

    # App
    default_user_id: str = "default"
    database_url: str = "sqlite:///./jaso_supporter.db"
    cors_origins: str = "*"
    rag_top_k: int = 5
    log_level: str = "INFO"

    # Auth (JWT). AUTH_REQUIRED=true 이면 Bearer 토큰 필수.
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
    def gemini_enabled(self) -> bool:
        return bool(self.google_api_key.strip())

    @property
    def ollama_enabled(self) -> bool:
        return self.llm_provider.strip().lower() == "ollama"

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
        return self.llm_provider.strip().lower() or "gemini"

    @property
    def allowed_gemini_models(self) -> list[str]:
        models = [
            item.strip()
            for item in self.gemini_allowed_models.split(",")
            if item.strip()
        ]
        default = self.gemini_model.strip()
        if default and default not in models:
            models.insert(0, default)
        return models

    def resolve_gemini_model(self, requested: str | None) -> str:
        """요청 모델이 허용 목록에 있으면 사용하고, 아니면 기본 모델로 폴백한다."""
        candidate = (requested or "").strip()
        allowed = self.allowed_gemini_models
        if candidate and candidate in allowed:
            return candidate
        return self.gemini_model

    @property
    def pinecone_enabled(self) -> bool:
        return bool(self.pinecone_api_key.strip())


@lru_cache
def get_settings() -> Settings:
    return Settings()
