"""서버측 Gemini 생성 서비스. 스트리밍/단건 텍스트 생성을 담당한다."""

from typing import Iterator, Optional

import google.generativeai as genai

from ..config import get_settings

_configured = False


def _ensure_configured() -> bool:
    global _configured
    settings = get_settings()
    if not settings.gemini_enabled:
        return False
    if not _configured:
        genai.configure(api_key=settings.google_api_key)
        _configured = True
    return True


def _build_parts(prompt: str, attachments: Optional[list[dict]]) -> list:
    parts: list = [prompt]
    for attachment in attachments or []:
        data = attachment.get("data")
        mime_type = attachment.get("mime_type")
        if data and mime_type:
            parts.append({"mime_type": mime_type, "data": data})
    return parts


def stream_text(prompt: str, attachments: Optional[list[dict]] = None) -> Iterator[str]:
    """토큰 청크를 순차적으로 yield 한다."""
    if not _ensure_configured():
        yield "[서버 오류] GOOGLE_API_KEY가 설정되지 않았습니다. 관리자에게 문의하세요."
        return

    settings = get_settings()
    model = genai.GenerativeModel(settings.gemini_model)
    try:
        response = model.generate_content(_build_parts(prompt, attachments), stream=True)
        for chunk in response:
            text = getattr(chunk, "text", None)
            if text:
                yield text
    except Exception as error:  # noqa: BLE001 - 사용자에게 읽을 수 있는 오류 전달
        yield f"\n[생성 중 오류가 발생했습니다: {error}]"


def generate_text(prompt: str, attachments: Optional[list[dict]] = None) -> str:
    return "".join(stream_text(prompt, attachments))
