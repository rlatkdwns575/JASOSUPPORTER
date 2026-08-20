"""자소서 초안 사실성 검사 (오프라인).

Experience STAR에 없는 수치·기관·기술 스택 삽입을 탐지한다.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field

from eval.generation_eval import extract_metric_numbers, has_unmentioned_company

# generation_eval 과 동일한 패턴 재사용
_NUMBER = re.compile(r"\d+(?:\.\d+)?%?")
_TECH_CANDIDATES = (
    "Python",
    "Java",
    "JavaScript",
    "TypeScript",
    "FastAPI",
    "Django",
    "Flask",
    "React",
    "Vue",
    "Node.js",
    "Spring",
    "Kotlin",
    "Go",
    "Rust",
    "C++",
    "C#",
    "SQL",
    "PostgreSQL",
    "MySQL",
    "MongoDB",
    "Redis",
    "Docker",
    "Kubernetes",
    "AWS",
    "GCP",
    "Azure",
    "Flutter",
    "Dart",
    "Excel",
    "Figma",
    "OpenAI",
    "Gemini",
)


@dataclass
class FactCheckResult:
    passed: bool
    violations: list[str] = field(default_factory=list)


def experience_facts_text(experience: dict) -> str:
    """Experience dict에서 사실 검사용 텍스트를 만든다."""
    parts: list[str] = [
        str(experience.get("title") or ""),
        str(experience.get("organization") or ""),
        str(experience.get("role") or ""),
        str(experience.get("situation") or ""),
        str(experience.get("task") or ""),
        str(experience.get("action") or ""),
        str(experience.get("result") or ""),
        str(experience.get("learned") or ""),
    ]
    tech = experience.get("techStacks") or experience.get("tech_stacks") or []
    if isinstance(tech, list):
        parts.extend(str(item) for item in tech)
    tags = experience.get("competencyTags") or experience.get("competency_tags") or []
    if isinstance(tags, list):
        parts.extend(str(item) for item in tags)
    return "\n".join(part for part in parts if part.strip())


def check_essay_facts(experience: dict, response: str) -> FactCheckResult:
    facts = experience_facts_text(experience)
    violations: list[str] = []

    bad_numbers = extract_metric_numbers(response) - extract_metric_numbers(facts)
    if bad_numbers:
        violations.append(f"허용되지 않은 수치: {', '.join(sorted(bad_numbers))}")

    if has_unmentioned_company(facts, response):
        violations.append("Experience에 없는 기관/회사명이 포함됨")

    facts_lower = facts.lower()
    for tech in _TECH_CANDIDATES:
        if tech.lower() in response.lower() and tech.lower() not in facts_lower:
            # 한글 문맥에서 영문 기술명만 검사
            if re.search(rf"\b{re.escape(tech)}\b", response, re.IGNORECASE):
                violations.append(f"Experience에 없는 기술 스택: {tech}")

    return FactCheckResult(passed=not violations, violations=violations)
