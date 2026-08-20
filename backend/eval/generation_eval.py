"""Generation hallucination 휴리스틱 평가.

LLM을 호출하지 않고, 응답 텍스트가 제공된 Experience 사실 집합 밖
수치·기업명 패턴을 쓰는지 검사한다.

사용:
  python -m eval.generation_eval
"""

from __future__ import annotations

import re
from dataclasses import dataclass


_NUMBER = re.compile(r"\d+(?:\.\d+)?%?")
_COMPANYISH = re.compile(
    r"(?:주식회사|㈜)\s*[A-Za-z0-9가-힣]+"
    r"|[A-Z][A-Za-z0-9]{2,}\s+(?:Inc|Corp|Ltd)\.?"
    r"|[A-Z][A-Za-z0-9]{2,}(?:Inc|Corp|Ltd)\.?"
)
_NON_COMPANY_TOKENS = frozenset(
    {
        "STAR",
        "API",
        "PM",
        "QA",
        "UI",
        "UX",
        "HR",
        "IT",
        "SDK",
        "JWT",
        "RAG",
        "SSE",
        "CRUD",
        "FastAPI",
    }
)


@dataclass
class EvalCase:
    experience_facts: str
    response: str
    expect_ok: bool
    name: str


CASES = [
    EvalCase(
        name="faithful",
        experience_facts="실패율 12% -> 3%, 역할: 백엔드",
        response="결제 실패율을 12%에서 3%로 낮췄습니다. 백엔드 담당으로 재시도 로직을 추가했습니다.",
        expect_ok=True,
    ),
    EvalCase(
        name="invented_metric",
        experience_facts="실패율 12% -> 3%",
        response="전환율을 45% 개선했고 MAU 120만 명을 달성했습니다.",
        expect_ok=False,
    ),
    EvalCase(
        name="invented_company",
        experience_facts="코딩 부트캠프",
        response="Google Inc 인턴으로 성과를 냈습니다.",
        expect_ok=False,
    ),
]


def extract_numbers(text: str) -> set[str]:
    return set(_NUMBER.findall(text))


def _strip_essay_noise(text: str) -> str:
    """글자 수·문항 번호 등 성과 수치가 아닌 숫자 문맥을 제거한다."""
    cleaned = text
    cleaned = re.sub(r"Q[1-6]", " ", cleaned)
    cleaned = re.sub(r"\d{2,4}\s*~\s*\d{2,4}\s*자", " ", cleaned)
    cleaned = re.sub(r"\d{2,4}\s*자\b", " ", cleaned)
    cleaned = re.sub(r"약\s*\d{2,4}\s*자", " ", cleaned)
    cleaned = re.sub(r"\(\s*\d{2,4}\s*~\s*\d{2,4}\s*자[^)]*\)", " ", cleaned)
    return cleaned


def extract_metric_numbers(text: str) -> set[str]:
    """자소서 본문에서 성과·지표로 볼 수 있는 수치만 추출한다."""
    numbers = extract_numbers(_strip_essay_noise(text))
    metrics: set[str] = set()
    for number in numbers:
        if number.endswith("%"):
            metrics.add(number)
            continue
        if not number.isdigit():
            metrics.add(number)
            continue
        value = int(number)
        if value <= 9:
            continue
        if 400 <= value <= 900:
            continue
        metrics.add(number)
    return metrics


def hallucinated_numbers(facts: str, response: str) -> set[str]:
    allowed = extract_metric_numbers(facts)
    used = extract_metric_numbers(response)
    return used - allowed


def has_unmentioned_company(facts: str, response: str) -> bool:
    facts_lower = facts.lower()
    for match in _COMPANYISH.findall(response):
        token = match.strip()
        if not token:
            continue
        if token.upper() in _NON_COMPANY_TOKENS:
            continue
        if token.lower() in facts_lower:
            continue
        return True
    return False


def evaluate(case: EvalCase) -> bool:
    bad_numbers = hallucinated_numbers(case.experience_facts, case.response)
    bad_company = has_unmentioned_company(case.experience_facts, case.response)
    ok = not bad_numbers and not bad_company
    return ok == case.expect_ok


def main() -> int:
    passed = 0
    for case in CASES:
        ok = evaluate(case)
        print(f"[{case.name}] {'PASS' if ok else 'FAIL'}")
        passed += int(ok)
    print(f"\n{passed}/{len(CASES)} passed")
    return 0 if passed == len(CASES) else 1


if __name__ == "__main__":
    raise SystemExit(main())
