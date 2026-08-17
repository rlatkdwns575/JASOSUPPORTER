"""인증·채팅방·헬스 플래그 테스트."""

from __future__ import annotations

from fastapi.testclient import TestClient


def test_register_rejects_short_password(client: TestClient) -> None:
    response = client.post(
        "/auth/register",
        json={"email": "short@example.com", "password": "1234567"},
    )
    assert response.status_code == 422


def test_register_login_me(client: TestClient) -> None:
    register = client.post(
        "/auth/register",
        json={"email": "user@example.com", "password": "password123"},
    )
    assert register.status_code == 200, register.text
    body = register.json()
    assert body["token_type"] == "bearer"
    assert body["email"] == "user@example.com"
    token = body["access_token"]

    me = client.get("/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert me.status_code == 200
    assert me.json()["auth"] == "jwt"
    assert me.json()["email"] == "user@example.com"

    login = client.post(
        "/auth/login",
        json={"email": "user@example.com", "password": "password123"},
    )
    assert login.status_code == 200
    assert login.json()["user_id"] == body["user_id"]


def test_jwt_scopes_experiences(client: TestClient) -> None:
    token_a = client.post(
        "/auth/register",
        json={"email": "a@example.com", "password": "password123"},
    ).json()["access_token"]
    token_b = client.post(
        "/auth/register",
        json={"email": "b@example.com", "password": "password123"},
    ).json()["access_token"]

    exp = {
        "id": "exp_auth_1",
        "title": "A only",
        "type": "project",
        "period": {},
        "organization": "",
        "role": "",
        "situation": "s",
        "task": "t",
        "action": "a",
        "result": "r",
        "learned": "l",
        "techStacks": [],
        "competencyTags": [],
        "evidenceLinks": [],
        "createdAt": "2025-01-01T00:00:00.000",
        "updatedAt": "2025-01-01T00:00:00.000",
    }
    assert (
        client.post(
            "/experiences",
            json=exp,
            headers={"Authorization": f"Bearer {token_a}"},
        ).status_code
        == 200
    )
    listed_b = client.get("/experiences", headers={"Authorization": f"Bearer {token_b}"})
    assert listed_b.status_code == 200
    assert listed_b.json() == []


def test_chat_room_persistence(client: TestClient, user_headers: dict[str, str]) -> None:
    room = {
        "id": "room_masterResume",
        "mode": "masterResume",
        "messages": [
            {"role": "user", "text": "안녕", "sentAt": "2025-01-01T00:00:00.000"},
            {"role": "assistant", "text": "안녕하세요", "sentAt": "2025-01-01T00:00:01.000"},
        ],
        "updatedAt": "2025-01-01T00:00:01.000",
    }
    assert client.post("/chat-rooms", json=room, headers=user_headers).status_code == 200
    got = client.get("/chat-rooms/room_masterResume", headers=user_headers)
    assert got.status_code == 200
    assert len(got.json()["messages"]) == 2
    assert client.delete("/chat-rooms/room_masterResume", headers=user_headers).status_code == 200


def test_health_includes_auth_flag(client: TestClient) -> None:
    health = client.get("/health")
    assert health.status_code == 200
    assert "authRequired" in health.json()
