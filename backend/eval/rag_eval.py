"""RAG 검색 품질 오프라인 평가.

사용:
  cd backend
  python -m eval.rag_eval

경험 픽스처를 임시 DB에 넣고 gold query 대비 hit@k / recall@k 를 출력한다.
실제 Pinecone 없이도 로컬 폴백 경로를 평가할 수 있다.
"""

from __future__ import annotations

import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

_tmp = tempfile.NamedTemporaryFile(suffix="_rag_eval.db", delete=False)
_tmp.close()
os.environ["DATABASE_URL"] = f"sqlite:///{_tmp.name}"

from app.db import init_db  # noqa: E402
from app.models import Experience  # noqa: E402
from app.services import rag  # noqa: E402
from app import store  # noqa: E402


def _seed() -> None:
    init_db()
    exp = {
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
    store.upsert(store.KIND_EXPERIENCE, "eval-user", exp["id"], exp)


def _retrieved_ids(context: str) -> list[str]:
    ids: list[str] = []
    for line in context.splitlines():
        line = line.strip()
        if line.startswith("- id:"):
            part = line.split(":", 1)[1].strip().split("/")[0].strip()
            if part:
                ids.append(part)
    return ids


def main() -> int:
    _seed()
    gold_path = Path(__file__).parent / "fixtures" / "gold_queries.json"
    cases = json.loads(gold_path.read_text(encoding="utf-8"))
    hits = 0
    total_with_relevant = 0
    for case in cases:
        ctx = rag.build_experience_context(
            user_id="eval-user",
            query=case["query"],
            selected_experience_ids=[],
        )
        got = set(_retrieved_ids(ctx))
        relevant = set(case.get("relevant_ids") or [])
        if relevant:
            total_with_relevant += 1
            if got & relevant:
                hits += 1
        print(f"[{case['id']}] query={case['query']!r} got={sorted(got)} relevant={sorted(relevant)}")
    hit_at_k = (hits / total_with_relevant) if total_with_relevant else 1.0
    print(f"\nhit@k={hit_at_k:.2f} ({hits}/{total_with_relevant})")
    return 0 if hit_at_k >= 0.5 else 1


if __name__ == "__main__":
    raise SystemExit(main())
