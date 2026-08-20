"""LLM 생성 Provider 추상화."""

from __future__ import annotations

from typing import Iterator, Optional, Protocol


class LlmProvider(Protocol):
    """텍스트 생성·스트리밍 인터페이스."""

    @property
    def provider_id(self) -> str:
        """gemini | ollama"""

    def stream_text(
        self,
        prompt: str,
        attachments: Optional[list[dict]] = None,
        model_name: Optional[str] = None,
    ) -> Iterator[str]:
        ...

    def generate_text(
        self,
        prompt: str,
        attachments: Optional[list[dict]] = None,
        model_name: Optional[str] = None,
    ) -> str:
        ...
