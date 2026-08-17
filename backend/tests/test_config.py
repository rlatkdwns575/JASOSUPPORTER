"""설정·보안 플래그 테스트."""

from app.config import DEFAULT_JWT_SECRET, Settings


def test_jwt_secret_is_default_detects_placeholder() -> None:
    settings = Settings(jwt_secret=DEFAULT_JWT_SECRET)
    assert settings.jwt_secret_is_default is True


def test_jwt_secret_is_default_accepts_long_custom_secret() -> None:
    settings = Settings(jwt_secret="this-is-a-long-production-secret-value")
    assert settings.jwt_secret_is_default is False
