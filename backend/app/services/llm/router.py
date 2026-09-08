"""LLM Provider — Ollama only."""

from __future__ import annotations

from typing import Optional

from .base import LlmProvider
from .ollama_provider import OllamaProvider

_ollama = OllamaProvider()


def get_llm_provider(requested: Optional[str] = None) -> LlmProvider:
    return _ollama


def resolve_provider_for_request(
    *,
    attachments: list[dict],
    requested_provider: Optional[str] = None,
) -> LlmProvider:
    return _ollama
