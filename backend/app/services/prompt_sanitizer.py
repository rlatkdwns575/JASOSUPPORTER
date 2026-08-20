"""프롬프트·Experience 컨텍스트 PII redaction 및 최소화."""

from __future__ import annotations

import re

_EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
_PHONE = re.compile(r"\b0\d{1,2}[-.\s]?\d{3,4}[-.\s]?\d{4}\b")
_RRN = re.compile(r"\b\d{6}[-\s]?\d{7}\b")


def redact_pii(text: str) -> str:
    if not text.strip():
        return text
    cleaned = _EMAIL.sub("[이메일]", text)
    cleaned = _PHONE.sub("[전화번호]", cleaned)
    cleaned = _RRN.sub("[주민번호]", cleaned)
    return cleaned


def sanitize_experience_context(context: str) -> str:
    return redact_pii(context)


def sanitize_prompt(prompt: str) -> str:
    return redact_pii(prompt)
