"""자소서 의미·표현 확장 점수 (오프라인 휴리스틱).

요약-only vs 사실 위에서의 해석·두괄·역량 전개를 proxy metric으로 채점한다.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

from eval.essay_fact_checker import experience_facts_text

_INSIGHT_MARKERS = (
    "인사이트",
    "배운",
    "깨달",
    "역량",
    "강점",
    "차별",
    "핵심",
    "메시지",
    "관점",
    "통찰",
    "성장",
    "개선",
    "문제해결",
    "협업",
    "주도",
)

_QUESTION_KEYWORDS: dict[str, tuple[str, ...]] = {
    "Q1": ("동기", "준비", "지원", "직무"),
    "Q2": ("강점", "성격", "특성", "보완"),
    "Q3": ("도전", "목표", "성취", "끈기"),
    "Q4": ("갈등", "팀", "협업", "조율", "화해"),
    "Q5": ("개선", "아이디어", "실행", "혁신", "문제"),
    "Q6": ("지원", "비전", "입사", "기여"),
}


@dataclass
class ExpansionScore:
    total: float
    deductive_opening: float
    insight_expansion: float
    question_fit: float
    summary_penalty: float
    notes: list[str]


def _tokenize(text: str) -> set[str]:
    normalized = "".join(ch.lower() if ch.isalnum() else " " for ch in text)
    return {token for token in normalized.split() if len(token) >= 2}


def _overlap_ratio(source: str, response: str) -> float:
    source_tokens = _tokenize(source)
    response_tokens = _tokenize(response)
    if not response_tokens:
        return 0.0
    return len(source_tokens & response_tokens) / len(response_tokens)


def _opening_text(response: str, max_chars: int = 180) -> str:
    stripped = response.strip()
    if not stripped:
        return ""
    first_break = stripped.find("\n")
    if first_break == -1 or first_break > max_chars:
        return stripped[:max_chars]
    return stripped[:first_break]


def score_essay_expansion(
    *,
    experience: dict,
    response: str,
    question_id: str,
    min_total: float = 0.35,
) -> ExpansionScore:
    facts = experience_facts_text(experience)
    notes: list[str] = []

    opening = _opening_text(response)
    deductive = 0.0
    if opening and any(marker in opening for marker in ("핵심", "강점", "역량", "저는", "이 경험")):
        deductive += 0.5
    if opening and not opening.startswith(("상황", "당시", "우선")):
        deductive += 0.3
    deductive = min(deductive, 1.0)

    insight = 0.0
    matched_markers = [m for m in _INSIGHT_MARKERS if m in response]
    if matched_markers:
        insight += min(0.4 + 0.1 * len(matched_markers), 1.0)
    learned = str(experience.get("learned") or "")
    tags = experience.get("competencyTags") or experience.get("competency_tags") or []
    tag_text = " ".join(str(t) for t in tags) if isinstance(tags, list) else ""
    bridge_source = f"{learned} {tag_text}"
    if bridge_source.strip() and any(token in response for token in _tokenize(bridge_source) if len(token) >= 2):
        insight += 0.2
    insight = min(insight, 1.0)

    question_fit = 0.0
    keywords = _QUESTION_KEYWORDS.get(question_id, ())
    if keywords:
        hits = sum(1 for kw in keywords if kw in response)
        question_fit = min(hits / max(len(keywords), 1), 1.0)

    overlap = _overlap_ratio(facts, response)
    summary_penalty = 0.0
    if overlap >= 0.55 and insight < 0.4:
        summary_penalty = min((overlap - 0.45) * 1.2, 0.6)
        notes.append(f"요약-only 의심 (overlap={overlap:.2f})")

    total = max(
        0.0,
        0.35 * deductive + 0.35 * insight + 0.30 * question_fit - summary_penalty,
    )
    if total < min_total:
        notes.append(f"확장 점수 미달 ({total:.2f} < {min_total:.2f})")

    return ExpansionScore(
        total=total,
        deductive_opening=deductive,
        insight_expansion=insight,
        question_fit=question_fit,
        summary_penalty=summary_penalty,
        notes=notes,
    )


def passes_expansion_gate(score: ExpansionScore, *, min_total: float = 0.35) -> bool:
    return score.total >= min_total
