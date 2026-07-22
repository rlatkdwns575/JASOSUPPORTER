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

    def embedding_text(self) -> str:
        """Pinecone 임베딩과 컨텍스트 주입에 쓰는 사실 텍스트."""
        parts: list[str] = []
        if self.title.strip():
            parts.append(f"제목: {self.title.strip()}")
        parts.append(f"유형: {self.type}")
        if self.organization.strip():
            parts.append(f"기관/소속: {self.organization.strip()}")
        if self.role.strip():
            parts.append(f"역할: {self.role.strip()}")
        if self.situation.strip():
            parts.append(f"상황: {self.situation.strip()}")
        if self.task.strip():
            parts.append(f"과제: {self.task.strip()}")
        if self.action.strip():
            parts.append(f"행동: {self.action.strip()}")
        if self.result.strip():
            parts.append(f"성과: {self.result.strip()}")
        if self.learned.strip():
            parts.append(f"배운 점: {self.learned.strip()}")
        if self.tech_stacks:
            parts.append("기술 스택: " + ", ".join(self.tech_stacks))
        if self.competency_tags:
            parts.append("역량 태그: " + ", ".join(self.competency_tags))
        return "\n".join(parts).strip()


class ChatMessageIn(CamelModel):
    role: str = "user"  # "user" | "assistant"
    text: str = ""


class ChatAttachment(CamelModel):
    name: str = ""
    mime_type: str = ""
    data_base64: str = ""


class ChatRequest(CamelModel):
    mode: str = "experienceSpec"  # experienceSpec | masterResume | portfolio
    messages: list[ChatMessageIn] = []
    attachment_text: str = ""
    target_job: str = ""
    selected_experience_ids: list[str] = []
    attachments: list[ChatAttachment] = []


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
