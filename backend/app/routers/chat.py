"""RAG 채팅 엔드포인트. 서버에서 시스템 프롬프트 + RAG 컨텍스트를 조립해 Gemini 스트리밍을 SSE 로 중계한다."""

import base64
import json
from typing import Iterator

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse

from ..config import get_settings
from ..deps import get_user_id
from ..models import ChatMessageIn, ChatRequest
from ..services import gemini_service, prompt_builder, rag

router = APIRouter(tags=["chat"])


def _decode_attachments(request: ChatRequest) -> list[dict]:
    decoded: list[dict] = []
    for attachment in request.attachments:
        if not attachment.data_base64:
            continue
        try:
            raw = base64.b64decode(attachment.data_base64)
        except Exception:
            continue
        decoded.append({"mime_type": attachment.mime_type or "application/octet-stream", "data": raw})
    return decoded


def _latest_user_text(messages: list[ChatMessageIn]) -> str:
    for message in reversed(messages):
        if message.role == "user" and message.text.strip():
            return message.text.strip()
    return ""


def _sse_stream(
    prompt: str,
    attachments: list[dict],
    model_name: str | None = None,
) -> Iterator[bytes]:
    for chunk in gemini_service.stream_text(prompt, attachments, model_name=model_name):
        if not chunk:
            continue
        payload = json.dumps({"t": chunk}, ensure_ascii=False)
        yield f"data: {payload}\n\n".encode("utf-8")
    yield b'data: {"done": true}\n\n'


def build_and_stream(
    *,
    user_id: str,
    mode: str,
    messages: list[ChatMessageIn],
    attachment_text: str,
    target_job: str,
    selected_experience_ids: list[str],
    attachments: list[dict],
    binary_file_names: list[str],
    model_name: str | None = None,
) -> StreamingResponse:
    experience_context = ""
    if mode in ("masterResume", "portfolio", "interview"):
        query = " ".join(
            part for part in [_latest_user_text(messages), target_job] if part
        ).strip()
        experience_context = rag.build_experience_context(
            user_id=user_id,
            query=query,
            selected_experience_ids=selected_experience_ids,
        )

    prompt = prompt_builder.build_chat_prompt(
        mode=mode,
        messages=messages,
        attachment_text=attachment_text,
        target_job=target_job,
        binary_file_names=binary_file_names,
        experience_context=experience_context,
    )

    return StreamingResponse(
        _sse_stream(prompt, attachments, model_name=model_name),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


@router.get("/models")
def list_models() -> dict:
    settings = get_settings()
    return {
        "defaultModel": settings.gemini_model,
        "models": settings.allowed_gemini_models,
    }


@router.post("/chat")
def chat(request: ChatRequest, user_id: str = Depends(get_user_id)) -> StreamingResponse:
    attachments = _decode_attachments(request)
    binary_file_names = [a.name for a in request.attachments if a.data_base64]
    return build_and_stream(
        user_id=user_id,
        mode=request.mode,
        messages=request.messages,
        attachment_text=request.attachment_text,
        target_job=request.target_job,
        selected_experience_ids=request.selected_experience_ids,
        attachments=attachments,
        binary_file_names=binary_file_names,
        model_name=request.model or None,
    )
