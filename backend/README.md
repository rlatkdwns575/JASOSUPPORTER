# JasoSupporter Backend (FastAPI)

Gemini·RAG·커리어 CRUD·JWT 인증을 담당합니다. API 키는 서버 `.env`에만 둡니다.

## 구조

```text
backend/
├─ app/
│  ├─ main.py / config.py / deps.py / db.py / store.py
│  ├─ logging_config.py / middleware_observability.py
│  ├─ routers/   auth, experiences, career, chat, chat_rooms, essay
│  └─ services/  auth, embedding, gemini, pinecone, rag, prompt_builder
├─ eval/         rag_eval, generation_eval
├─ tests/
├─ docker-compose.yml   # Postgres
└─ requirements.txt
```

## 실행

```bash
cd backend
python -m venv .venv
.venv\Scripts\Activate.ps1   # Windows
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload --port 8000
```

### PostgreSQL

```bash
docker compose up -d
# .env
DATABASE_URL=postgresql+psycopg://jaso:jaso@localhost:5432/jaso_supporter
```

SQLite는 단일 노드 개발용입니다. 배포 시 Postgres + `CORS_ORIGINS`에 웹 도메인을 지정하세요.

## 인증

| 설정 | 동작 |
|------|------|
| `Authorization: Bearer <jwt>` | `sub` = user_id (권장) |
| `AUTH_REQUIRED=false` (기본) | Bearer 없으면 `X-User-Id` / `userId` soft 폴백 |
| `AUTH_REQUIRED=true` | Bearer 필수 |

엔드포인트: `POST /auth/register`, `POST /auth/login`, `GET /auth/me`

## 주요 API

| 경로 | 설명 |
|------|------|
| `/health` | gemini/pinecone/authRequired |
| `/models`, `/chat` | 모델 목록, AI SSE |
| `/chat-rooms` | 코치 대화 영속화 |
| `/experiences` | CRUD + 임베딩 upsert (role/skills/result 메타) |
| career CRUD | spec, essays, portfolio, applications, interview |
| `/essay/draft`, `/essay/full-review` | `/chat` 편의 래퍼 |

## 관측·로깅

- `LOG_LEVEL` (기본 INFO)
- Embedding/Pinecone 예외는 `logger.exception`으로 기록 후 degrade
- `ObservabilityMiddleware`가 method/path/status/latency_ms 로그

## 평가

```bash
pytest
python -m eval.rag_eval
python -m eval.generation_eval
```

- RAG: gold query hit@k (로컬 폴백 포함)
- Generation: 응답의 미제공 수치·기업명 휴리스틱

## RAG 요약

1. 경험 저장 시 STAR + role/skills/competencies/result 메타 upsert
2. 검색 시 top-k*2 조회 후 키워드 overlap rerank
3. Pinecone/임베딩 실패 시 로컬 최근 경험 폴백
