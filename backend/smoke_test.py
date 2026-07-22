"""의존성 설치 후 앱 구동/라우팅을 확인하는 간단 스모크 테스트.

API 키 없이도 저장소 CRUD 와 SSE 파이프라인(키 없음 안내 메시지 포함)이 동작하는지 확인한다.
"""

import os
import tempfile

# 격리된 임시 DB 사용.
_tmp_db = os.path.join(tempfile.gettempdir(), "jaso_smoke.db")
if os.path.exists(_tmp_db):
    os.remove(_tmp_db)
os.environ["DATABASE_URL"] = f"sqlite:///{_tmp_db}"

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402


def run(client: TestClient) -> None:
    # 1) health
    health = client.get("/health")
    assert health.status_code == 200, health.text
    print("health:", health.json())

    # 2) experience 저장/조회/삭제 라운드트립
    experience = {
        "id": "exp_smoke_1",
        "title": "부트캠프 최종 프로젝트",
        "type": "bootcamp",
        "period": {"start": "2025-01-01T00:00:00.000", "end": "2025-03-01T00:00:00.000"},
        "organization": "코딩 부트캠프",
        "role": "백엔드 담당",
        "situation": "결제 실패율이 높았다",
        "task": "실패 원인 분석",
        "action": "재시도 로직과 로깅 추가",
        "result": "실패율 12% -> 3%",
        "learned": "관측 가능성의 중요성",
        "techStacks": ["Python", "FastAPI"],
        "competencyTags": ["문제해결"],
        "evidenceLinks": [],
        "createdAt": "2025-03-02T00:00:00.000",
        "updatedAt": "2025-03-02T00:00:00.000",
    }
    saved = client.post("/experiences", json=experience)
    assert saved.status_code == 200, saved.text
    assert saved.json()["id"] == "exp_smoke_1"

    listed = client.get("/experiences")
    assert listed.status_code == 200
    assert any(item["id"] == "exp_smoke_1" for item in listed.json())
    print("experiences count:", len(listed.json()))

    single = client.get("/experiences/exp_smoke_1")
    assert single.status_code == 200
    assert single.json()["title"] == "부트캠프 최종 프로젝트"

    # 3) 보조 엔티티 저장
    spec = {
        "id": "spec_1",
        "type": "certificate",
        "title": "정보처리기사",
        "value": "2024 취득",
        "issuedAt": "2024-05",
        "createdAt": "2024-05-01T00:00:00.000",
        "updatedAt": "2024-05-01T00:00:00.000",
    }
    assert client.post("/spec-items", json=spec).status_code == 200
    assert len(client.get("/spec-items").json()) == 1

    # 4) chat SSE (키 없어도 안내 메시지 스트림 확인)
    chat_body = {
        "mode": "masterResume",
        "messages": [{"role": "user", "text": "Q3 초안 부탁해"}],
        "targetJob": "백엔드 엔지니어",
        "selectedExperienceIds": ["exp_smoke_1"],
    }
    with client.stream("POST", "/chat", json=chat_body) as response:
        assert response.status_code == 200, response.text
        collected = "".join(chunk for chunk in response.iter_text())
    assert "data:" in collected, collected
    print("chat stream ok (len=%d)" % len(collected))

    # 5) 삭제
    assert client.delete("/experiences/exp_smoke_1").status_code == 200
    assert not any(item["id"] == "exp_smoke_1" for item in client.get("/experiences").json())

    print("\nSMOKE TEST PASSED")


if __name__ == "__main__":
    # 컨텍스트 매니저로 진입해 lifespan(startup: init_db)을 실행한다.
    with TestClient(app) as smoke_client:
        run(smoke_client)
