"""서버측 Gemini 생성 서비스. 스트리밍/단건 텍스트 생성을 담당한다."""

from typing import Iterator, Optional

from google.genai import types

from ..config import get_settings
from .gemini_client import get_genai_client


def _build_contents(prompt: str, attachments: Optional[list[dict]]) -> list:
    parts: list = [prompt]
    for attachment in attachments or []:
        data = attachment.get("data")
        mime_type = attachment.get("mime_type")
        if data and mime_type:
            parts.append(types.Part.from_bytes(data=data, mime_type=mime_type))
    return parts


def stream_text(
    prompt: str,
    attachments: Optional[list[dict]] = None,
    model_name: Optional[str] = None,
) -> Iterator[str]:
    """토큰 청크를 순차적으로 yield 한다."""
    client = get_genai_client()
    if client is None:
        yield "[서버 오류] GOOGLE_API_KEY가 설정되지 않았습니다. 관리자에게 문의하세요."
        return

    settings = get_settings()
    resolved = settings.resolve_gemini_model(model_name)
    try:
        for chunk in client.models.generate_content_stream(
            model=resolved,
            contents=_build_contents(prompt, attachments),
        ):
            text = getattr(chunk, "text", None)
            if text:
                yield text
    except Exception as error:  # noqa: BLE001 - 사용자에게 읽을 수 있는 오류 전달
        yield f"\n[생성 중 오류가 발생했습니다: {error}]"


def generate_text(
    prompt: str,
    attachments: Optional[list[dict]] = None,
    model_name: Optional[str] = None,
) -> str:
    return "".join(stream_text(prompt, attachments, model_name=model_name))
