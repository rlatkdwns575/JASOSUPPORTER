"""자소서 오프라인 eval — 사실성 hard gate + 의미 확장 soft score.

사용:
  cd backend
  python -m eval.essay_eval
"""

from __future__ import annotations

import json
from pathlib import Path

from eval.essay_expansion_scorer import passes_expansion_gate, score_essay_expansion
from eval.essay_fact_checker import check_essay_facts
from eval.generation_eval import CASES as GENERATION_CASES, evaluate as evaluate_generation

FIXTURE_PATH = Path(__file__).parent / "fixtures" / "essay_eval_cases.json"
MIN_EXPANSION_TOTAL = 0.35


def load_cases() -> list[dict]:
    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


def run_fixture_case(case: dict) -> tuple[bool, list[str]]:
    messages: list[str] = []
    experience = case["experience"]
    question_id = case["question_id"]

    good = case["good_response"]
    good_facts = check_essay_facts(experience, good)
    if not good_facts.passed:
        messages.append(f"{case['id']} good_response fact FAIL: {good_facts.violations}")
    good_score = score_essay_expansion(
        experience=experience,
        response=good,
        question_id=question_id,
        min_total=MIN_EXPANSION_TOTAL,
    )
    if not passes_expansion_gate(good_score, min_total=MIN_EXPANSION_TOTAL):
        messages.append(
            f"{case['id']} good_response expansion FAIL: total={good_score.total:.2f} "
            f"notes={good_score.notes}"
        )

    bad_fact = case["bad_fact_response"]
    bad_fact_result = check_essay_facts(experience, bad_fact)
    if bad_fact_result.passed:
        messages.append(f"{case['id']} bad_fact_response should fail fact check")

    bad_summary = case["bad_summary_response"]
    bad_summary_score = score_essay_expansion(
        experience=experience,
        response=bad_summary,
        question_id=question_id,
        min_total=MIN_EXPANSION_TOTAL,
    )
    if passes_expansion_gate(bad_summary_score, min_total=MIN_EXPANSION_TOTAL):
        messages.append(
            f"{case['id']} bad_summary_response should score below gate "
            f"(total={bad_summary_score.total:.2f})"
        )

    return (not messages, messages)


def main() -> int:
    passed = 0
    total = 0

    for case in GENERATION_CASES:
        total += 1
        ok = evaluate_generation(case)
        print(f"[generation:{case.name}] {'PASS' if ok else 'FAIL'}")
        passed += int(ok)

    for case in load_cases():
        total += 1
        ok, messages = run_fixture_case(case)
        print(f"[essay:{case['id']}] {'PASS' if ok else 'FAIL'}")
        for message in messages:
            print(f"  - {message}")
        passed += int(ok)

    print(f"\n{passed}/{total} passed")
    return 0 if passed == total else 1


if __name__ == "__main__":
    raise SystemExit(main())
