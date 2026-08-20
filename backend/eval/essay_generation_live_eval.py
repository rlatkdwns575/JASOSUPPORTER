"""자소서 live eval — LLM 실호출 + LLM-as-judge(Gemini).

CI에는 포함하지 않는다. provider별 사전 조건이 없으면 skip(exit 0).
엄격 모드: --require-api-key

사용:
  cd backend
  python -m eval.essay_generation_live_eval
  python -m eval.essay_generation_live_eval --provider ollama
  python -m eval.essay_generation_live_eval --require-api-key
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
from app.services import gemini_service, prompt_builder  # noqa: E402
from app.services.llm import get_llm_provider  # noqa: E402
from app.services.rag import build_selected_experience_context  # noqa: E402
from app import store  # noqa: E402
from app.db import init_db  # noqa: E402
from eval.essay_eval import FIXTURE_PATH, load_cases  # noqa: E402
from eval.essay_expansion_scorer import score_essay_expansion  # noqa: E402
from eval.essay_fact_checker import check_essay_facts  # noqa: E402
from eval.essay_judge import build_judge_prompt, parse_judge_response  # noqa: E402

USER_ID = "essay-live-eval-user"


def _seed_experience(experience: dict) -> None:
    store.upsert(store.KIND_EXPERIENCE, USER_ID, experience["id"], experience)


def _question_body(question_id: str) -> str:
    for item in prompt_builder.MASTER_QUESTIONS:
        if item["id"] == question_id:
            return str(item["body"])
    return question_id


def _index_for_question(question_id: str) -> int:
    for index, item in enumerate(prompt_builder.MASTER_QUESTIONS):
        if item["id"] == question_id:
            return index
    return 0


def generate_essay(case: dict, *, provider: str) -> str:
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
    llm = get_llm_provider(provider)
    return llm.generate_text(prompt).strip()


def run_case(case: dict, *, provider: str) -> dict:
    essay = generate_essay(case, provider=provider)
    fact = check_essay_facts(case["experience"], essay)
    expansion = score_essay_expansion(
        experience=case["experience"],
        response=essay,
        question_id=case["question_id"],
    )

    judge_raw = gemini_service.generate_text(
        build_judge_prompt(
            experience=case["experience"],
            question_id=case["question_id"],
            question_body=_question_body(case["question_id"]),
            essay=essay,
        )
    )
    judge = parse_judge_response(judge_raw)

    return {
        "case_id": case["id"],
        "essay_preview": essay[:240] + ("..." if len(essay) > 240 else ""),
        "fact_passed": fact.passed,
        "fact_violations": fact.violations,
        "expansion_total": round(expansion.total, 3),
        "judge_fact_fidelity": judge.fact_fidelity,
        "judge_meaning_expansion": judge.meaning_expansion,
        "judge_summary_only": judge.summary_only,
        "judge_passed": judge.passed,
        "judge_notes": judge.notes,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Live master-essay eval with LLM + judge")
    parser.add_argument(
        "--cases",
        default=str(FIXTURE_PATH),
        help="Path to essay eval fixture JSON",
    )
    parser.add_argument(
        "--provider",
        choices=["gemini", "ollama"],
        default="gemini",
        help="Essay generation provider (judge always uses Gemini)",
    )
    parser.add_argument(
        "--require-api-key",
        action="store_true",
        help="Exit 1 when GOOGLE_API_KEY is missing (judge + gemini generation)",
    )
    args = parser.parse_args()

    # live eval은 선택 경험 주입만 사용한다. Pinecone/임베딩 설정 오류 로그를 막는다.
    os.environ["PINECONE_API_KEY"] = ""
    os.environ["LLM_PROVIDER"] = args.provider

    get_settings.cache_clear()
    settings = get_settings()
    if not settings.gemini_enabled:
        message = "GOOGLE_API_KEY not configured; judge step unavailable."
        print(message)
        if args.require_api_key:
            return 1
        if args.provider == "gemini":
            print("Skipping live essay eval (gemini provider).")
            return 0
        print("Skipping live essay eval (judge requires Gemini API key).")
        return 0
    if args.provider == "ollama":
        print(f"Generation provider: ollama ({settings.ollama_model})")
    else:
        print(f"Generation provider: gemini ({settings.gemini_model})")

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
            result = run_case(case, provider=args.provider)
        except Exception as error:  # noqa: BLE001
            print(f"FAIL: {error}")
            results.append({"case_id": case["id"], "error": str(error)})
            continue
        ok = result["fact_passed"] and result["judge_passed"]
        print(f"fact={'PASS' if result['fact_passed'] else 'FAIL'} "
              f"expansion={result['expansion_total']:.2f} "
              f"judge={result['judge_fact_fidelity']}/{result['judge_meaning_expansion']} "
              f"summary_only={result['judge_summary_only']} "
              f"=> {'PASS' if ok else 'FAIL'}")
        if result["fact_violations"]:
            print("  violations:", result["fact_violations"])
        if result["judge_notes"]:
            print("  notes:", result["judge_notes"])
        results.append(result)
        passed += int(ok)

    report_path = Path(__file__).parent / "reports"
    report_path.mkdir(exist_ok=True)
    report_name = (
        "essay_live_ollama_latest.json"
        if args.provider == "ollama"
        else "essay_live_eval_latest.json"
    )
    out_file = report_path / report_name
    out_file.write_text(json.dumps(results, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"\nReport: {out_file}")
    print(f"{passed}/{len(cases)} passed")
    return 0 if passed == len(cases) else 1


if __name__ == "__main__":
    raise SystemExit(main())
