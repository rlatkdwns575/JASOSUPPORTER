"""LLM-as-judge rubric for master essay generation."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass

JUDGE_SYSTEM = """\
너는 자소서 품질 평가자다. 아래 2축으로 1~5점을 매긴다.

1) fact_fidelity (1~5)
   - 5: Experience 사실만 사용, 새 수치·기관·역할·행동 invent 없음
   - 3: 대체로 faithful, 경미한 과장
   - 1: 명백한 허위 사실·수치·기관 invent

2) meaning_expansion (1~5)
   - 5: STAR 요약-only가 아님. 두괄·강점·인사이트·차별화가 사실 위에서 전개됨
   - 3: 사실은 맞지만 표현 확장이 약함
   - 1: Experience STAR를 거의 그대로 재서술

반드시 JSON만 출력:
{
  "fact_fidelity": 1,
  "meaning_expansion": 1,
  "summary_only": true,
  "violations": ["..."],
  "notes": "..."
}
"""


@dataclass
class JudgeResult:
    fact_fidelity: int
    meaning_expansion: int
    summary_only: bool
    violations: list[str]
    notes: str

    @property
    def passed(self) -> bool:
        return self.fact_fidelity >= 4 and self.meaning_expansion >= 3 and not self.summary_only


def build_judge_prompt(*, experience: dict, question_id: str, question_body: str, essay: str) -> str:
    from eval.essay_fact_checker import experience_facts_text

    facts = experience_facts_text(experience)
    return (
        f"{JUDGE_SYSTEM}\n\n"
        f"[문항] {question_id}: {question_body}\n\n"
        f"[Experience 사실]\n{facts}\n\n"
        f"[생성 자소서]\n{essay.strip()}\n"
    )


_JSON_BLOCK = re.compile(r"\{[\s\S]*\}")


def parse_judge_response(raw: str) -> JudgeResult:
    match = _JSON_BLOCK.search(raw)
    if not match:
        raise ValueError(f"Judge JSON not found: {raw[:200]}")
    data = json.loads(match.group())
    violations = data.get("violations") or []
    if not isinstance(violations, list):
        violations = [str(violations)]
    return JudgeResult(
        fact_fidelity=int(data.get("fact_fidelity", 0)),
        meaning_expansion=int(data.get("meaning_expansion", 0)),
        summary_only=bool(data.get("summary_only", False)),
        violations=[str(v) for v in violations],
        notes=str(data.get("notes") or "").strip(),
    )
