"""핵심 API 경로 회귀 테스트 (API 키 없이 CRUD·SSE 형태 검증)."""

from __future__ import annotations

from fastapi.testclient import TestClient


def _experience(exp_id: str = "exp_test_1") -> dict:
    return {
        "id": exp_id,
        "title": "부트캠프 최종 프로젝트",
        "type": "bootcamp",
        "period": {
            "start": "2025-01-01T00:00:00.000",
            "end": "2025-03-01T00:00:00.000",
        },
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


def test_health(client: TestClient) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert "gemini" in body
    assert "pinecone" in body
    assert body["genaiSdk"] == "google-genai"
    assert "embeddingDimension" in body
    assert "pineconeDimensionMismatch" in body
    assert isinstance(body["jwtSecretConfigured"], bool)


def test_experience_roundtrip(client: TestClient, user_headers: dict[str, str]) -> None:
    saved = client.post("/experiences", json=_experience(), headers=user_headers)
    assert saved.status_code == 200
    assert saved.json()["id"] == "exp_test_1"

    listed = client.get("/experiences", headers=user_headers)
    assert listed.status_code == 200
    assert any(item["id"] == "exp_test_1" for item in listed.json())

    # 다른 유저 네임스페이스에는 보이지 않아야 한다.
    other = client.get("/experiences", headers={"X-User-Id": "other-user"})
    assert other.status_code == 200
    assert not any(item["id"] == "exp_test_1" for item in other.json())

    deleted = client.delete("/experiences/exp_test_1", headers=user_headers)
    assert deleted.status_code == 200
    assert not any(
        item["id"] == "exp_test_1"
        for item in client.get("/experiences", headers=user_headers).json()
    )


def test_master_essay_and_version_delete(
    client: TestClient, user_headers: dict[str, str]
) -> None:
    essay = {
        "id": "master_essay_Q1",
        "questionId": "Q1",
        "questionText": "지원 동기",
        "targetJob": "백엔드",
        "linkedExperienceIds": [],
        "currentVersionId": "v1",
        "createdAt": "2025-03-02T00:00:00.000",
        "updatedAt": "2025-03-02T00:00:00.000",
    }
    version = {
        "id": "v1",
        "masterEssayId": "master_essay_Q1",
        "body": "초안 본문",
        "createdAt": "2025-03-02T00:00:00.000",
        "sourceExperienceIds": [],
    }
    assert client.post("/master-essays", json=essay, headers=user_headers).status_code == 200
    assert client.post("/essay-versions", json=version, headers=user_headers).status_code == 200

    versions = client.get(
        "/essay-versions",
        params={"masterEssayId": "master_essay_Q1"},
        headers=user_headers,
    )
    assert versions.status_code == 200
    assert len(versions.json()) == 1

    # 버전만 삭제
    assert client.delete("/essay-versions/v1", headers=user_headers).status_code == 200
    assert (
        client.get(
            "/essay-versions",
            params={"masterEssayId": "master_essay_Q1"},
            headers=user_headers,
        ).json()
        == []
    )

    # 버전 다시 저장 후 마스터 삭제 시 버전 cascade
    assert client.post("/essay-versions", json=version, headers=user_headers).status_code == 200
    assert client.delete("/master-essays/master_essay_Q1", headers=user_headers).status_code == 200
    assert client.get("/master-essays/master_essay_Q1", headers=user_headers).status_code == 404
    assert (
        client.get(
            "/essay-versions",
            params={"masterEssayId": "master_essay_Q1"},
            headers=user_headers,
        ).json()
        == []
    )


def test_chat_sse_shape(client: TestClient, user_headers: dict[str, str]) -> None:
    client.post("/experiences", json=_experience("exp_chat_1"), headers=user_headers)
    body = {
        "mode": "masterResume",
        "messages": [{"role": "user", "text": "Q3 초안 부탁해"}],
        "targetJob": "백엔드 엔지니어",
        "selectedExperienceIds": ["exp_chat_1"],
    }
    with client.stream("POST", "/chat", json=body, headers=user_headers) as response:
        assert response.status_code == 200
        collected = "".join(chunk for chunk in response.iter_text())
    assert "data:" in collected
