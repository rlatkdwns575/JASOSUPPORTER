# JasoSupporter Backend (FastAPI)

로컬 Ollama(`jaso-coach`)·커리어 CRUD·JWT 인증을 담당합니다.  
생성 LLM은 **서버의 Ollama**만 사용합니다. Google API 키는 필요하지 않습니다.

학습·Modelfile은 [jasosupporter-ml](../../jasosupporter-ml)를 사용하세요.

## 구조

```text
backend/
├─ app/
│  ├─ main.py / config.py / deps.py / db.py / store.py
│  ├─ routers/   auth, experiences, career, chat, chat_rooms, essay
│  └─ services/  auth, llm (ollama), rag, prompt_builder, …
├─ eval/         generation_eval (휴리스틱)
├─ tests/
├─ docker-compose.yml   # Postgres
└─ requirements.txt
```

## 실행

1. Ollama에서 `jaso-coach` 준비 (`jasosupporter-ml` README)
2. 백엔드:

```bash
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1   # Windows
pip install -r requirements.txt
copy .env.example .env
# LLM_PROVIDER=ollama
# OLLAMA_MODEL=jaso-coach
uvicorn app.main:app --reload --port 8000
```

### PostgreSQL

```bash
docker compose up -d
DATABASE_URL=postgresql+psycopg://jaso:jaso@localhost:5432/jaso_supporter
```

프로덕션 체크리스트는 [DEPLOY.md](./DEPLOY.md)를 참고하세요.

## 인증

| 설정 | 동작 |
|------|------|
| `Authorization: Bearer <jwt>` | `sub` = user_id (권장) |
| `AUTH_REQUIRED=false` (기본) | Bearer 없으면 `X-User-Id` soft 폴백 |
| `AUTH_REQUIRED=true` | Bearer 필수 |

## 주요 API

| 경로 | 설명 |
|------|------|
| `/health` | llmProvider / ollama / auth |
| `/models`, `/chat` | Ollama 모델 목록, AI SSE |
| `/chat-rooms` | 코치 대화 영속화 |
| `/experiences` | CRUD (선택 경험은 채팅 시 카드 컨텍스트로 주입) |
| career CRUD | spec, essays, portfolio, applications, interview |
| `/essay/draft`, `/essay/full-review` | `/chat` 편의 래퍼 |

## 경험 컨텍스트

- 기본: 사용자가 고른 Experience ID를 카드 텍스트로 프롬프트에 삽입
- 미선택 시: 로컬 DB의 최근 경험 `RAG_TOP_K`개 폴백 (벡터 DB 없음)

## 평가

```bash
pytest
python -m eval.generation_eval
```

Generation eval은 미제공 수치·기업명 휴리스틱 위주입니다.
