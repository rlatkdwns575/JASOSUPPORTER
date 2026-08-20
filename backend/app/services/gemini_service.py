"""Gemini 생성 서비스 (하위 호환 re-export)."""

from typing import Iterator, Optional

from .llm.gemini_provider import GeminiProvider

_provider = GeminiProvider()


def stream_text(
    prompt: str,
    attachments: Optional[list[dict]] = None,
    model_name: Optional[str] = None,
) -> Iterator[str]:
    yield from _provider.stream_text(prompt, attachments, model_name=model_name)


def generate_text(
    prompt: str,
    attachments: Optional[list[dict]] = None,
    model_name: Optional[str] = None,
) -> str:
    return _provider.generate_text(prompt, attachments, model_name=model_name)
