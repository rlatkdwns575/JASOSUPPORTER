"""요청/응답 스키마. Flutter 도메인 모델과 camelCase JSON 필드를 1:1로 맞춘다.

- Experience: lib/domain/models/experience.dart 와 동일
- 그 외 커리어 엔티티는 유연하게 dict 로 저장하므로 라우터에서 직접 다룬다.
"""

from typing import Optional

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class CamelModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
        extra="ignore",
    )


class DateRange(CamelModel):
    start: Optional[str] = None
    end: Optional[str] = None


class Experience(CamelModel):
    id: str = ""
    title: str = ""
    type: str = "other"
    period: DateRange = DateRange()
    organization: str = ""
    role: str = ""
    situation: str = ""
    task: str = ""
    action: str = ""
    result: str = ""
    learned: str = ""
    tech_stacks: list[str] = []
    competency_tags: list[str] = []
    evidence_links: list[str] = []
    created_at: str = ""
    updated_at: str = ""


class ChatMessageIn(CamelModel):
    role: str = "user"  # "user" | "assistant"
    text: str = ""


class ChatAttachment(CamelModel):
    name: str = ""
    mime_type: str = ""
    data_base64: str = ""


class ChatRequest(CamelModel):
    mode: str = "experienceSpec"  # experienceSpec | masterResume | portfolio | interview
    messages: list[ChatMessageIn] = []
    attachment_text: str = ""
    target_job: str = ""
    selected_experience_ids: list[str] = []
    attachments: list[ChatAttachment] = []
    # 선택 Ollama 모델. 비어 있거나 허용 목록 밖이면 서버 기본값 사용.
    model: str = ""


class EssayDraftRequest(CamelModel):
    index0_based: int = 0
    user_draft: str = ""
    target_job: str = ""
    selected_experience_ids: list[str] = []
    messages: list[ChatMessageIn] = []
    attachment_text: str = ""


class EssayFullReviewRequest(CamelModel):
    full_draft: str = ""
    target_job: str = ""
    messages: list[ChatMessageIn] = []
    attachment_text: str = ""
