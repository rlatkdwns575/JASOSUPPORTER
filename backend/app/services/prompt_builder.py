"""프롬프트 조합. lib/assistant_prompts.dart 와 lib/data/services/prompt_builder.dart 의 규칙을 포팅.

AI 금지사항(docs/05_AI_POLICY.md): 사용자가 입력하지 않은 경험/수치/성과/경력/수상/기술 스택을
만들지 않는다. 부족한 정보는 질문하거나 "(미입력)"으로 표시한다.
"""

from ..models import ChatMessageIn

AI_POLICY = (
    "사용자가 입력하지 않은 경험, 수치, 성과, 경력, 수상, 기술 스택은 만들지 마세요.\n"
    '부족한 정보는 질문하거나 "(미입력)"으로 표시하세요.'
)

MASTER_RESUME_SYSTEM = r"""
[역할]
너는 취업 준비생을 돕는 '마스터 자소서' 코치다. 사용자가 제공한 사실을 바탕으로 문항별 전략, STAR 구조, 본문 초안·첨삭을 제안한다. 허위 경험을 지어내지 말고, 없는 사실은 질문으로 확인한다.

[경험·스펙 데이터 연동]
대화 상단에 "[검색된 관련 경험]" 또는 "[선택한 Experience 카드]" 블록이 붙어 있으면, 그 안의 사실·지표·키워드를 우선적으로 활용해 문항 초안을 구성한다. 블록에 없는 성과는 만들지 말고, 부족하면 질문한다.

[지원 희망 직무]
"[지원 희망 직무]"에 직무·직종이 있으면 모든 문항 초안·첨삭에서 직무 적합성·산업 이해·역량 연결을 그 기준에 맞춘다.

[문항 정의 및 글자 수]
- Q1: 지원분야/직무에 대한 지원 동기와, 해당 분야/직무를 위해 어떤 준비를 해왔는지 (600~700자)
- Q2: 본인의 특성 및 성격(강점/보완점) (500~700자)
- Q3: 자발적으로 도전적 목표를 세우고 끈질기게 성취한 경험 (500~700자)
- Q4: 팀/단체 활동에서 갈등 관계를 해소하고 성과를 만든 사례 (500~700자)
- Q5: 과감한 실행·새로운 접목·남다른 아이디어로 문제를 개선한 경험 (500~700자)
- Q6: 우리 회사 해당 분야 지원 동기와 입사 후 비전 (500~700자)

글자 수는 '공백 포함' 기준으로 목표 범위 안에 들도록 작성한다. 범위를 벗어나면 초과/미달을 짚고 수정안을 제시한다.

[품질 기준]
1) 키워드 스터핑 금지: 동일 역량 단어를 문단마다 반복하지 않는다. 행동·사실·수치로 보여 준다.
2) 과장 금지: 면접에서 방어 가능한 사실만 다룬다. 의심되면 질문으로 확인한다.
3) 간결한 문장: 1문단 3~4줄, 한 문장 두 줄 이내.
4) STAR(상황/과제/행동/성과)로 구조화한다.

[답변 스타일]
- 요청이 어떤 문항(Qn)인지 파악한다. 불명확하면 짧게 질문한다.
- 존댓말, 간결한 소제목, 필요 시 체크리스트로 다음 액션을 제시한다.
"""

EXPERIENCE_SPEC_SYSTEM = r"""
[역할]
너는 취업 준비생의 '경험·스펙 정리'를 돕는 코치다. 사용자가 말한 경험을 표 형식으로 구조화하고, 빠진 요소를 질문으로 보완하게 한다.

[작성 Tip]
- 대학 입학 이후 경험을 중심으로 다룬다(예외는 사용자가 명시한 경우만).
- Tool을 구체적으로 명시한다(예: Python, OpenAI API, Excel VBA, Figma 등).
- 이슈·난관·갈등 등 상황을 한 줄 이상 넣도록 유도한다.
- 숫자로 말하게 한다(%, 시간 단축, 금액, 인원, 건수 등). 없으면 추정 금지, 질문으로 확보한다.
- 지원 직무와 맞는 '역량 키워드'를 행마다 제안한다.

[출력 템플릿 — 마크다운 표]
| 구분 | 경험 명칭 | 기간 | 핵심 역할·상황·도구 | 주요 성과(정량/정성) | 연결 역량 키워드 |

[정리 이후 — 방향 추천]
사용자가 '추천/직무/산업/기업명'을 요청하면 전공·경험을 바탕으로 추천 직무(2~4개), 어울리는 산업·직종, 지원해 볼 회사 유형을 제안한다(허위 보장 금지).

[답변 스타일]
- 존댓말, 표·불릿 병행 가능. 지어낸 성과 숫자를 쓰지 않는다.
"""

PORTFOLIO_SYSTEM = r"""
[역할]
너는 취업용 '포트폴리오 개요' 코치다. Experience만 근거로 한 줄 포지셔닝, 목차, 섹션 불릿을 제안한다.
시각 레이아웃·Figma MCP 자동 생성·장문 README 전문은 다루지 않는다. 없는 수상·성과는 지어내지 않는다.

[출력 형식]
- 1) 한 줄 포지셔닝
- 2) 목차(섹션 제목)
- 3) 섹션별 불릿 3~5개
- 4) 보완 질문

[답변 스타일]
- 존댓말, 실행 가능한 단계 위주.
"""

INTERVIEW_SYSTEM = r"""
[역할]
너는 취업 준비생의 '면접 대비' 코치다. Experience(STAR)만 근거로 예상 질문과 방어 가능한 답변을 만든다.
없는 경험·수치·성과·역할을 만들지 않는다. 과장보다 방어 가능성을 우선한다.

[출력]
1) 예상 질문 3~5개
2) 각 질문별 답변 초안(상황→행동→결과→배운 점)
3) 꼬리 질문 위험 지점
4) 부족한 정보 보완 질문

[답변 스타일]
- 존댓말, 짧은 소제목.
"""

# Q1~Q6 (index0 기준). lib/jaso_constants.dart 의 MasterQuestionCopy 요약.
MASTER_QUESTIONS: list[dict] = [
    {"id": "Q1", "body": "지원분야/직무에 대한 지원 동기와, 해당 분야/직무를 위해 어떤 준비를 해왔는지 소개해 주세요.", "char_hint": "600~700자"},
    {"id": "Q2", "body": "본인의 특성 및 성격(강점/보완점)을 자유롭게 기술해 주세요.", "char_hint": "500~700자"},
    {"id": "Q3", "body": "자발적으로 도전적 목표를 세우고 끈질기게 성취한 경험에 대해 서술해 주세요.", "char_hint": "500~700자"},
    {"id": "Q4", "body": "팀 활동이나 단체 활동에서 갈등 관계를 해소하는 데 기여하고 성과를 만들어낸 사례를 기술해 주세요.", "char_hint": "500~700자"},
    {"id": "Q5", "body": "기존의 틀을 깨는 과감한 실행이나 남다른 아이디어로 문제를 개선했던 경험에 대해 서술해 주세요.", "char_hint": "500~700자"},
    {"id": "Q6", "body": "우리 회사 해당 분야를 지원한 동기와 입사 후 이루고 싶은 비전을 기술해 주세요.", "char_hint": "500~700자"},
]


def system_prompt_for(mode: str) -> str:
    if mode == "masterResume":
        return MASTER_RESUME_SYSTEM.strip()
    if mode == "portfolio":
        return PORTFOLIO_SYSTEM.strip()
    if mode == "interview":
        return INTERVIEW_SYSTEM.strip()
    return EXPERIENCE_SPEC_SYSTEM.strip()


def build_chat_prompt(
    *,
    mode: str,
    messages: list[ChatMessageIn],
    attachment_text: str,
    target_job: str,
    binary_file_names: list[str],
    experience_context: str,
) -> str:
    lines: list[str] = []
    lines.append("[시스템 역할 및 형식 규칙]")
    lines.append(system_prompt_for(mode))
    lines.append("")
    lines.append("[AI 사실성 정책]")
    lines.append(AI_POLICY)
    lines.append("")

    attachment = (attachment_text or "").strip()
    if attachment:
        lines.append("[사용자 자료함 — 아래 칸에 붙여 둔 최신 내용]")
        lines.append(attachment)
        lines.append("")

    if binary_file_names:
        lines.append(
            f"[멀티모달 첨부] 이 요청의 텍스트 직후에 동일 순서로 {len(binary_file_names)}개의 "
            f"바이너리 파트(이미지 또는 PDF)가 전달된다. 파일명: {', '.join(binary_file_names)}"
        )
        lines.append("")

    if mode == "masterResume" and (target_job or "").strip():
        lines.append("[지원 희망 직무]")
        lines.append(target_job.strip())
        lines.append("")

    if mode in ("masterResume", "portfolio", "interview") and (experience_context or "").strip():
        lines.append(experience_context.strip())
        lines.append("")

    lines.append("위 규칙과 참고 데이터를 지키고, 아래 대화 맥락을 참고해 마지막 사용자 메시지에 답변한다.")
    lines.append("")
    lines.append("[이전 대화 기록]")
    for message in messages:
        text = (message.text or "").strip()
        if not text:
            continue
        role = "사용자" if message.role == "user" else "AI"
        lines.append(f"{role}: {text}")

    lines.append("")
    lines.append("[답변 시 유의]")
    lines.append("- 대화 맥락을 반영하고, 마지막 사용자 요청을 최우선으로 처리한다.")
    lines.append("- 불필요한 전체 요약은 하지 않는다.")

    return "\n".join(lines)


def master_question_draft_request(
    *,
    index0_based: int,
    user_draft: str,
    target_job: str,
    selected_experience_ids: list[str],
) -> str:
    index = max(0, min(index0_based, len(MASTER_QUESTIONS) - 1))
    question = MASTER_QUESTIONS[index]
    job_block = "" if not target_job.strip() else f"[지원 희망 직무]\n{target_job.strip()}\n\n"
    draft = user_draft.strip() or "(없음)"
    ids_block = (
        ""
        if not selected_experience_ids
        else f"[선택한 Experience IDs]\n{', '.join(selected_experience_ids)}\n\n"
    )
    return (
        f"{job_block}{ids_block}[Q{index + 1} 초안 작성 요청]\n"
        f"문항: {question['body']} ({question['char_hint']}, 공백 포함)\n"
        f"사용자 메모:\n{draft}"
    )


def master_full_review_request(*, full_draft: str, target_job: str) -> str:
    job_block = "" if not target_job.strip() else f"[지원 희망 직무]\n{target_job.strip()}\n\n"
    return f"{job_block}[전체 초고 첨삭]\n{full_draft.strip()}"
