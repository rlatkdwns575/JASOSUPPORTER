"""오프라인 자소서 eval 단위 테스트."""

from eval.essay_expansion_scorer import passes_expansion_gate, score_essay_expansion
from eval.essay_fact_checker import check_essay_facts
from eval.essay_judge import parse_judge_response


EXPERIENCE = {
    "title": "부트캠프 최종 프로젝트",
    "organization": "코딩 부트캠프",
    "role": "백엔드 담당",
    "situation": "결제 실패율이 높았다",
    "task": "실패 원인 분석",
    "action": "재시도 로직 추가",
    "result": "실패율 12% -> 3%",
    "learned": "관측 가능성",
    "techStacks": ["Python", "FastAPI"],
    "competencyTags": ["문제해결"],
}


def test_fact_checker_rejects_invented_metric() -> None:
    result = check_essay_facts(EXPERIENCE, "전환율 45%를 달성했습니다.")
    assert not result.passed


def test_fact_checker_accepts_faithful_response() -> None:
    result = check_essay_facts(
        EXPERIENCE,
        "재시도 로직을 추가해 실패율을 12%에서 3%로 낮췄습니다.",
    )
    assert result.passed


def test_fact_checker_ignores_char_count_and_star_noise() -> None:
    result = check_essay_facts(
        EXPERIENCE,
        "STAR 구조로 작성했습니다. 공백 포함 588자 분량으로, 500~700자 범위에 맞췄습니다. "
        "재시도 로직을 추가해 실패율을 12%에서 3%로 낮췄습니다.",
    )
    assert result.passed


def test_expansion_scorer_prefers_interpretation_over_summary() -> None:
    expanded = score_essay_expansion(
        experience=EXPERIENCE,
        response=(
            "저는 데이터 기반으로 문제를 좁혀 해결하는 역량이 강점입니다. "
            "재시도 로직을 추가해 실패율을 12%에서 3%로 낮췄고, "
            "관측 가능성의 중요성이라는 인사이트를 얻었습니다."
        ),
        question_id="Q3",
    )
    summary = score_essay_expansion(
        experience=EXPERIENCE,
        response="결제 실패율이 높았다. 실패 원인 분석. 재시도 로직 추가. 실패율 12% -> 3%.",
        question_id="Q3",
    )
    assert expanded.total > summary.total
    assert passes_expansion_gate(expanded)


def test_judge_parser_reads_json() -> None:
    raw = '{"fact_fidelity": 5, "meaning_expansion": 4, "summary_only": false, "violations": [], "notes": "ok"}'
    result = parse_judge_response(raw)
    assert result.passed
    assert result.fact_fidelity == 5
