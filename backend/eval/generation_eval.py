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
_COMPANYISH = re.compile(r"(?:주식회사|㈜)?\s*[A-Z][A-Za-z0-9]{2,}(?:\s*(?:Inc|Corp|Ltd)\.?)?")


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


def hallucinated_numbers(facts: str, response: str) -> set[str]:
    allowed = extract_numbers(facts)
    used = extract_numbers(response)
    return used - allowed


def has_unmentioned_company(facts: str, response: str) -> bool:
    for match in _COMPANYISH.findall(response):
        token = match.strip()
        if token and token.lower() not in facts.lower():
            # 영문 대문자 시작 토큰만 검사
            if re.search(r"[A-Z]", token):
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
