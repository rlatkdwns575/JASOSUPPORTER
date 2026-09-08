"""경험 컨텍스트(선택 주입·최근 폴백) 테스트."""

from app import store
from app.services import rag


def _exp(exp_id: str, *, title: str, updated: str) -> dict:
    return {
        "id": exp_id,
        "title": title,
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
        "createdAt": updated,
        "updatedAt": updated,
    }


def test_build_selected_experience_context() -> None:
    uid = "rag-selected-user"
    store.upsert(store.KIND_EXPERIENCE, uid, "exp_a", _exp("exp_a", title="A", updated="2025-03-02T00:00:00.000"))
    store.upsert(store.KIND_EXPERIENCE, uid, "exp_b", _exp("exp_b", title="B", updated="2025-03-03T00:00:00.000"))

    ctx = rag.build_selected_experience_context(
        user_id=uid,
        selected_experience_ids=["exp_a"],
    )
    assert "선택한 Experience" in ctx
    assert "exp_a" in ctx
    assert "A" in ctx
    assert "exp_b" not in ctx


def test_build_experience_context_recent_fallback() -> None:
    uid = "rag-fallback-user"
    store.upsert(store.KIND_EXPERIENCE, uid, "exp_old", _exp("exp_old", title="Old", updated="2025-01-01T00:00:00.000"))
    store.upsert(store.KIND_EXPERIENCE, uid, "exp_new", _exp("exp_new", title="New", updated="2025-06-01T00:00:00.000"))

    ctx = rag.build_experience_context(
        user_id=uid,
        query="anything",
        selected_experience_ids=[],
    )
    assert "최근 경험" in ctx
    assert "exp_new" in ctx
    assert ctx.index("exp_new") < ctx.index("exp_old")
