"""Ollama 로컬 LLM Provider (HTTP /api/generate stream)."""

from __future__ import annotations

import json
from typing import Iterator, Optional

import httpx

from ...config import get_settings


class OllamaProvider:
    @property
    def provider_id(self) -> str:
        return "ollama"

    def _resolve_model(self, model_name: Optional[str]) -> str:
        settings = get_settings()
        candidate = (model_name or "").strip()
        if candidate and candidate in settings.allowed_ollama_models:
            return candidate
        return settings.ollama_model

    def stream_text(
        self,
        prompt: str,
        attachments: Optional[list[dict]] = None,
        model_name: Optional[str] = None,
    ) -> Iterator[str]:
        if attachments:
            yield (
                "[로컬 AI] Ollama 모델은 텍스트만 지원합니다. "
                "첨부 파일이 있으면 CLOUD_AI_ENABLED=true 및 Gemini로 전환하세요."
            )
            return

        settings = get_settings()
        url = f"{settings.ollama_base_url.rstrip('/')}/api/generate"
        payload = {
            "model": self._resolve_model(model_name),
            "prompt": prompt,
            "stream": True,
        }
        try:
            with httpx.Client(timeout=settings.ollama_timeout_sec) as client:
                with client.stream("POST", url, json=payload) as response:
                    response.raise_for_status()
                    for line in response.iter_lines():
                        if not line:
                            continue
                        try:
                            data = json.loads(line)
                        except json.JSONDecodeError:
                            continue
                        chunk = data.get("response")
                        if isinstance(chunk, str) and chunk:
                            yield chunk
                        if data.get("done") is True:
                            break
        except httpx.ConnectError:
            yield (
                "[로컬 AI 오류] Ollama에 연결할 수 없습니다. "
                f"Ollama가 실행 중인지 확인하세요 ({settings.ollama_base_url})."
            )
        except Exception as error:  # noqa: BLE001
            yield f"\n[로컬 AI 생성 중 오류: {error}]"

    def generate_text(
        self,
        prompt: str,
        attachments: Optional[list[dict]] = None,
        model_name: Optional[str] = None,
    ) -> str:
        return "".join(self.stream_text(prompt, attachments, model_name=model_name))
