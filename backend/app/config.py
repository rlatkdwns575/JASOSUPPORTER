"""애플리케이션 설정. 모든 비밀 키는 이 계층(.env)에서만 로드된다."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

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

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def gemini_enabled(self) -> bool:
        return bool(self.google_api_key.strip())

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
