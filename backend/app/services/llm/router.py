"""설정에 따른 LLM Provider 선택."""

from __future__ import annotations

from typing import Optional

from ...config import get_settings
from .base import LlmProvider
from .gemini_provider import GeminiProvider
from .ollama_provider import OllamaProvider

_gemini = GeminiProvider()
_ollama = OllamaProvider()


def get_llm_provider(requested: Optional[str] = None) -> LlmProvider:
    settings = get_settings()
    provider = (requested or settings.llm_provider or "gemini").strip().lower()
    if provider == "ollama":
        return _ollama
    return _gemini


def resolve_provider_for_request(
    *,
    attachments: list[dict],
    requested_provider: Optional[str] = None,
) -> LlmProvider:
    """첨부가 있으면 Gemini 폴백(cloud 허용 시), 아니면 설정 provider."""
    settings = get_settings()
    provider = get_llm_provider(requested_provider)
    if attachments and provider.provider_id == "ollama":
        if settings.cloud_ai_enabled and settings.gemini_enabled:
            return _gemini
    return provider
