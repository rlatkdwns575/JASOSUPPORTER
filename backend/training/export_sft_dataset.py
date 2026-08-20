"""essay_eval fixture → SFT JSONL export.

사용:
  cd backend
  python -m training.export_sft_dataset
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from app.services.prompt_builder import AI_POLICY, MASTER_QUESTIONS, MASTER_RESUME_SYSTEM  # noqa: E402
from eval.essay_expansion_scorer import passes_expansion_gate, score_essay_expansion  # noqa: E402
from eval.essay_fact_checker import check_essay_facts, experience_facts_text  # noqa: E402

FIXTURE_PATH = ROOT / "eval" / "fixtures" / "essay_eval_cases.json"
OUTPUT_PATH = Path(__file__).parent / "datasets" / "jaso_coach_sft.jsonl"


def _question_body(question_id: str) -> tuple[str, str]:
    for item in MASTER_QUESTIONS:
        if item["id"] == question_id:
            return question_id, str(item["body"])
    return question_id, question_id


def _build_user_content(experience: dict, question_id: str) -> str:
    qid, body = _question_body(question_id)
    facts = experience_facts_text(experience)
    return (
        "[선택한 Experience 카드 — 사실만 인용할 것]\n"
        f"{facts}\n\n"
        f"[{qid} 초안 작성 요청]\n"
        f"문항: {body}\n"
        "지원 희망 직무: 백엔드 개발자"
    )


def _system_content() -> str:
    return f"{MASTER_RESUME_SYSTEM.strip()}\n\n[AI 사실성 정책]\n{AI_POLICY}"


def export_cases(cases: list[dict]) -> list[dict]:
    rows: list[dict] = []
    for case in cases:
        experience = case["experience"]
        question_id = case["question_id"]
        assistant = str(case["good_response"]).strip()
        fact = check_essay_facts(experience, assistant)
        if not fact.passed:
            print(f"skip {case['id']}: fact violations {fact.violations}")
            continue
        expansion = score_essay_expansion(
            experience=experience,
            response=assistant,
            question_id=question_id,
        )
        if not passes_expansion_gate(expansion):
            print(f"skip {case['id']}: low expansion {expansion.total:.2f}")
            continue
        rows.append(
            {
                "messages": [
                    {"role": "system", "content": _system_content()},
                    {"role": "user", "content": _build_user_content(experience, question_id)},
                    {"role": "assistant", "content": assistant},
                ]
            }
        )
    return rows


def main() -> int:
    cases = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))
    rows = export_cases(cases)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_PATH.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")
    print(f"Wrote {len(rows)} rows to {OUTPUT_PATH}")
    return 0 if rows else 1


if __name__ == "__main__":
    raise SystemExit(main())
