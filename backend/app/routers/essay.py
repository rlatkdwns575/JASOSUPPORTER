"""마스터 자소서 초안/전체 첨삭 편의 엔드포인트.

공식 AI 진입점은 `POST /chat` 이다. Flutter 앱도 `/chat` + 클라이언트 지시문을 사용한다.

이 라우트의 `/essay/draft`, `/essay/full-review`는 서버에서 문항 지시문을 조립한 뒤
동일한 chat 파이프라인(시스템 프롬프트 + RAG + Gemini 스트리밍)을 재사용하는
편의 API이며, 외부 클라이언트·스크립트용으로 유지한다.
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
