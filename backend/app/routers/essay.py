"""마스터 자소서 초안/전체 첨삭 엔드포인트.

문항별 지시문(instruction)을 서버에서 조립해 마지막 사용자 메시지로 붙인 뒤,
chat 파이프라인(시스템 프롬프트 + RAG + Gemini 스트리밍)을 재사용한다.
"""

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse

from ..deps import get_user_id
from ..models import ChatMessageIn, EssayDraftRequest, EssayFullReviewRequest
from ..services import prompt_builder
from .chat import build_and_stream

router = APIRouter(prefix="/essay", tags=["essay"])


@router.post("/draft")
def essay_draft(request: EssayDraftRequest, user_id: str = Depends(get_user_id)) -> StreamingResponse:
    instruction = prompt_builder.master_question_draft_request(
        index0_based=request.index0_based,
        user_draft=request.user_draft,
        target_job=request.target_job,
        selected_experience_ids=request.selected_experience_ids,
    )
    messages = list(request.messages) + [ChatMessageIn(role="user", text=instruction)]
    return build_and_stream(
        user_id=user_id,
        mode="masterResume",
        messages=messages,
        attachment_text=request.attachment_text,
        target_job=request.target_job,
        selected_experience_ids=request.selected_experience_ids,
        attachments=[],
        binary_file_names=[],
    )


@router.post("/full-review")
def essay_full_review(request: EssayFullReviewRequest, user_id: str = Depends(get_user_id)) -> StreamingResponse:
    instruction = prompt_builder.master_full_review_request(
        full_draft=request.full_draft,
        target_job=request.target_job,
    )
    messages = list(request.messages) + [ChatMessageIn(role="user", text=instruction)]
    return build_and_stream(
        user_id=user_id,
        mode="masterResume",
        messages=messages,
        attachment_text=request.attachment_text,
        target_job=request.target_job,
        selected_experience_ids=[],
        attachments=[],
        binary_file_names=[],
    )
