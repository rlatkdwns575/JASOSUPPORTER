# 프라이버시·AI 아키텍처

JasoSupporter는 사용자 경력 데이터를 **로컬 DB가 Source of Truth**로 두고, AI는 선택·폴백된 Experience만 근거로 답합니다.

## 추론 경로 (A)

| 모드 | 데이터 흐름 | 외부 API |
|------|-------------|----------|
| Ollama (기본) | Flutter → FastAPI → Ollama (로컬) | **미호출** |

로컬 모드 기본:

- **선택 Experience** 컨텍스트 주입 (미선택 시 최근 경험 `RAG_TOP_K`)
- 외부 벡터DB·클라우드 임베딩 **없음**
- `prompt_sanitizer`로 이메일·전화·주민번호 형식 redaction

## 학습 경로 (B)

| 단계 | 설명 |
|------|------|
| Gold / SFT | `jasosupporter-ml` 파이프라인 |
| QLoRA | ML 레포에서 학습 후 Ollama `jaso-coach` |

**범위 밖 (장기):** PriFFT / PPFT — 오픈 가중치 + 로컬 학습 파이프라인 확립 후 검토.

## 경험 컨텍스트 (구 RAG)

- SoT: 로컬 SQLite Experience 카드
- 주입: 선택 ID → 카드 사실 텍스트 → 프롬프트
- 자소서·포트폴리오 전문은 외부 인덱스에 올리지 않음

## 환경 변수

```env
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_MODEL=jaso-coach
RAG_TOP_K=5
```

## 헬스·감사

`GET /health`:

- `llmProvider`, `ollamaConfigured`, `cloudAiEnabled`, `localModel`

Flutter **설정 → 백엔드 연결**에서 AI 제공자·로컬 상태를 확인합니다.

## AI 금지사항

`docs/05_AI_POLICY.md` — 허위 경험·수치·과장 금지. 부족하면 보완 질문.
