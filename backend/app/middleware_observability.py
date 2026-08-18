"""요청 latency / status 관측 미들웨어."""

from __future__ import annotations

import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from .logging_config import get_logger

logger = get_logger("observability")

_SKIP_LOG_PATHS = frozenset({"/health", "/favicon.ico"})


class ObservabilityMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        started = time.perf_counter()
        status_code = 500
        try:
            response = await call_next(request)
            status_code = response.status_code
            return response
        except Exception:
            logger.exception("unhandled error path=%s", request.url.path)
            raise
        finally:
            if request.url.path not in _SKIP_LOG_PATHS:
                elapsed_ms = (time.perf_counter() - started) * 1000
                logger.info(
                    "request method=%s path=%s status=%s latency_ms=%.1f",
                    request.method,
                    request.url.path,
                    status_code,
                    elapsed_ms,
                )
