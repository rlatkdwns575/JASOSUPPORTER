# 프라이버시·AI 아키텍처

JasoSupporter는 사용자 경력 데이터를 **로컬 DB가 Source of Truth**로 두고, AI는 선택·검색된 Experience만 근거로 답합니다.

## 추론 경로 (A)

| 모드 | 데이터 흐름 | Google API |
|------|-------------|------------|
| `LLM_PROVIDER=ollama` | Flutter → FastAPI → Ollama (로컬 GPU) | **미호출** |
| `LLM_PROVIDER=gemini` | Flutter → FastAPI → Gemini | 호출 (프롬프트 plaintext) |
| 첨부(PDF/이미지) + Ollama | `CLOUD_AI_ENABLED=true` 시 Gemini 폴백 | 호출 |

로컬 모드 기본:

- Pinecone 벡터 검색 **생략** (`skip_vector_search`)
- **선택 Experience** 컨텍스트만 주입
- `prompt_sanitizer`로 이메일·전화·주민번호 형식 redaction

## 학습 경로 (B — 실용)

| 단계 | 설명 |
|------|------|
| SFT 데이터 | essay eval fixture + 수동 확장 → `training/datasets/*.jsonl` |
| QLoRA | `training/train_qlora.py` (FastAPI 밖) |
| 배포 | Ollama `jaso-coach` Modelfile |

**범위 밖 (장기):** PriFFT / PPFT — 클라우드 Gemini만으로는 적용 불가. 오픈 가중치 + 로컬 학습 파이프라인 확립 후 검토.

## RAG·벡터DB

- 벡터 인덱스: Experience **요약·STAR 메타**만 (`id` + vector)
- 자소서·포트폴리오 전문은 벡터 인덱싱 **금지**
- RAG = 벡터 id 검색 → 로컬 DB hydrate → LLM

## 환경 변수

```env
LLM_PROVIDER=ollama|gemini
CLOUD_AI_ENABLED=true|false
OLLAMA_BASE_URL=http://127.0.0.1:11434
OLLAMA_MODEL=jaso-coach
```

## 헬스·감사

`GET /health`:

- `llmProvider`, `ollamaConfigured`, `cloudAiEnabled`, `localModel`

Flutter **설정 → 백엔드 연결**에서 AI 제공자·로컬/클라우드 상태를 확인합니다.

## AI 금지사항

`docs/05_AI_POLICY.md` — 허위 경험·수치·과장 금지. 부족하면 보완 질문.
