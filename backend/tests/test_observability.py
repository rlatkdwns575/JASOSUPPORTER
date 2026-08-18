"""관측 미들웨어 유틸 테스트."""

from app.middleware_observability import _SKIP_LOG_PATHS


def test_health_path_is_skipped_from_request_logs() -> None:
    assert "/health" in _SKIP_LOG_PATHS
    assert "/experiences" not in _SKIP_LOG_PATHS
