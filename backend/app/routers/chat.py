"""RAG 채팅 엔드포인트. 서버에서 시스템 프롬프트 + RAG 컨텍스트를 조립해 LLM 스트리밍을 SSE 로 중계한다."""

import base64
import json
from typing import Iterator

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse

from ..config import get_settings
from ..deps import get_user_id
from ..models import ChatMessageIn, ChatRequest
from ..services import prompt_builder, rag
from ..services.llm.router import resolve_provider_for_request
from ..services.prompt_sanitizer import sanitize_experience_context, sanitize_prompt

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
    provider = resolve_provider_for_request(attachments=attachments)
    for chunk in provider.stream_text(prompt, attachments, model_name=model_name):
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
    settings = get_settings()
    skip_vector = settings.active_llm_provider == "ollama"

    experience_context = ""
    if mode in ("masterResume", "portfolio", "interview"):
        if skip_vector and selected_experience_ids:
            experience_context = rag.build_selected_experience_context(
                user_id=user_id,
                selected_experience_ids=selected_experience_ids,
            )
        else:
            query = " ".join(
                part for part in [_latest_user_text(messages), target_job] if part
            ).strip()
            experience_context = rag.build_experience_context(
                user_id=user_id,
                query=query,
                selected_experience_ids=selected_experience_ids,
                skip_vector_search=skip_vector,
            )
        experience_context = sanitize_experience_context(experience_context)

    prompt = prompt_builder.build_chat_prompt(
        mode=mode,
        messages=messages,
        attachment_text=attachment_text,
        target_job=target_job,
        binary_file_names=binary_file_names,
        experience_context=experience_context,
    )
    prompt = sanitize_prompt(prompt)

    return StreamingResponse(
        _sse_stream(prompt, attachments, model_name=model_name),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"},
    )


@router.get("/models")
def list_models() -> dict:
    settings = get_settings()
    if settings.active_llm_provider == "ollama":
        models = settings.allowed_ollama_models
        return {
            "provider": "ollama",
            "defaultModel": settings.ollama_model,
            "models": models,
            "cloudAiEnabled": settings.cloud_ai_enabled,
        }
    return {
        "provider": "gemini",
        "defaultModel": settings.gemini_model,
        "models": settings.allowed_gemini_models,
        "cloudAiEnabled": settings.cloud_ai_enabled,
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
