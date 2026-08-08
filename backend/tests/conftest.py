"""pytest 공통 픽스처.

앱 모듈 import 전에 임시 SQLite DATABASE_URL 을 고정한다.
"""

from __future__ import annotations

import os
import tempfile
from collections.abc import Generator

# app.* import 전에 DB 경로를 격리한다.
_fd, _DB_PATH = tempfile.mkstemp(suffix="_jaso_pytest.db")
os.close(_fd)
os.environ["DATABASE_URL"] = f"sqlite:///{_DB_PATH}"

import pytest  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


@pytest.fixture()
def client() -> Generator[TestClient, None, None]:
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture()
def user_headers() -> dict[str, str]:
    return {"X-User-Id": "pytest-user"}
