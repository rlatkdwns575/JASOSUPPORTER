"""자소서 live eval — Ollama 실호출 + 휴리스틱 채점 (클라우드 judge 없음).

CI에는 포함하지 않는다. Ollama/jaso-coach 없으면 skip(exit 0).

사용:
  cd backend
  python -m eval.essay_generation_live_eval
  python -m eval.essay_generation_live_eval --require-ollama
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from app.config import get_settings  # noqa: E402
from app.models import ChatMessageIn  # noqa: E402
from app.services import prompt_builder  # noqa: E402
from app.services.llm import get_llm_provider  # noqa: E402
from app.services.rag import build_selected_experience_context  # noqa: E402
from app import store  # noqa: E402
from app.db import init_db  # noqa: E402
from eval.essay_eval import FIXTURE_PATH  # noqa: E402
from eval.essay_expansion_scorer import score_essay_expansion  # noqa: E402
from eval.essay_fact_checker import check_essay_facts  # noqa: E402

USER_ID = "essay-live-eval-user"


def _seed_experience(experience: dict) -> None:
    store.upsert(store.KIND_EXPERIENCE, USER_ID, experience["id"], experience)


def _index_for_question(question_id: str) -> int:
    for index, item in enumerate(prompt_builder.MASTER_QUESTIONS):
        if item["id"] == question_id:
            return index
    return 0


def generate_essay(case: dict) -> str:
    experience = case["experience"]
    question_id = case["question_id"]
    index = _index_for_question(question_id)

    instruction = prompt_builder.master_question_draft_request(
        index0_based=index,
        user_draft="",
        target_job="백엔드 개발자",
        selected_experience_ids=[experience["id"]],
    )
    experience_context = build_selected_experience_context(
        user_id=USER_ID,
        selected_experience_ids=[experience["id"]],
    )
    prompt = prompt_builder.build_chat_prompt(
        mode="masterResume",
        messages=[ChatMessageIn(role="user", text=instruction)],
        attachment_text="",
        target_job="백엔드 개발자",
        binary_file_names=[],
        experience_context=experience_context,
    )
    llm = get_llm_provider()
    return llm.generate_text(prompt).strip()


def run_case(case: dict) -> dict:
    essay = generate_essay(case)
    fact = check_essay_facts(case["experience"], essay)
    expansion = score_essay_expansion(
        experience=case["experience"],
        response=essay,
        question_id=case["question_id"],
    )
    return {
        "case_id": case["id"],
        "essay_preview": essay[:240] + ("..." if len(essay) > 240 else ""),
        "fact_passed": fact.passed,
        "fact_violations": fact.violations,
        "expansion_total": round(expansion.total, 3),
        "heuristic_passed": fact.passed and expansion.total >= 0.5,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Live master-essay eval via Ollama")
    parser.add_argument("--cases", default=str(FIXTURE_PATH))
    parser.add_argument(
        "--require-ollama",
        action="store_true",
        help="Exit 1 when Ollama connection/model fails",
    )
    args = parser.parse_args()

    os.environ["LLM_PROVIDER"] = "ollama"
    get_settings.cache_clear()
    settings = get_settings()
    print(f"Generation provider: ollama ({settings.ollama_model})")

    cases = json.loads(Path(args.cases).read_text(encoding="utf-8"))
    if not cases:
        print("No cases found.")
        return 1

    tmp = tempfile.NamedTemporaryFile(suffix="_essay_live_eval.db", delete=False)
    tmp.close()
    os.environ["DATABASE_URL"] = f"sqlite:///{tmp.name}"
    get_settings.cache_clear()
    init_db()

    results: list[dict] = []
    passed = 0
    for case in cases:
        _seed_experience(case["experience"])
        print(f"\n=== {case['id']} ===")
        try:
            result = run_case(case)
        except Exception as error:  # noqa: BLE001
            print(f"FAIL: {error}")
            results.append({"case_id": case["id"], "error": str(error)})
            if args.require_ollama:
                return 1
            continue
        if result["essay_preview"].startswith("[로컬 AI"):
            print(f"SKIP: {result['essay_preview'][:120]}")
            if args.require_ollama:
                return 1
            results.append(result)
            continue
        ok = result["heuristic_passed"]
        print(
            f"fact={'PASS' if result['fact_passed'] else 'FAIL'} "
            f"expansion={result['expansion_total']:.2f} => {'PASS' if ok else 'FAIL'}"
        )
        if result["fact_violations"]:
            print("  violations:", result["fact_violations"])
        results.append(result)
        passed += int(ok)

    report_path = Path(__file__).parent / "reports"
    report_path.mkdir(exist_ok=True)
    out_file = report_path / "essay_live_ollama_latest.json"
    out_file.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nReport: {out_file}")
    print(f"{passed}/{len(cases)} passed")
    return 0 if passed == len(cases) else 1


if __name__ == "__main__":
    raise SystemExit(main())
