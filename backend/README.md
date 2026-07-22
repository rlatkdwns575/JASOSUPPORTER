# JasoSupporter Backend (FastAPI)

Flutter 프론트엔드용 백엔드입니다. Gemini 호출, Pinecone 기반 RAG, 커리어 데이터 저장을 담당합니다.
모든 API 키는 서버 `.env` 에만 두며 클라이언트에 노출되지 않습니다.

## 구조

```text
backend/
├─ app/
│  ├─ main.py            # FastAPI 앱, CORS, 라우터 등록, /health
│  ├─ config.py          # pydantic-settings (.env 로드)
│  ├─ deps.py            # user_id 의존성 (단일 사용자, 네임스페이스 대비)
│  ├─ models.py          # Experience 등 Pydantic 스키마 (Flutter camelCase 일치)
│  ├─ db.py              # SQLite(SQLModel) 문서 테이블
│  ├─ store.py           # 문서 CRUD 헬퍼
│  ├─ routers/
│  │  ├─ experiences.py  # Experience CRUD + Pinecone upsert
│  │  ├─ career.py       # 스펙/자소서/포트폴리오/지원 기록 CRUD
│  │  ├─ chat.py         # RAG 채팅 (SSE 스트리밍)
│  │  └─ essay.py        # 마스터 자소서 초안/전체 첨삭
│  └─ services/
│     ├─ embedding.py       # Gemini text-embedding-004 (768차원)
│     ├─ gemini_service.py  # 생성 스트리밍
│     ├─ pinecone_service.py
│     ├─ rag.py             # 검색 + 컨텍스트 조립 (Pinecone 없으면 로컬 폴백)
│     └─ prompt_builder.py  # 시스템 프롬프트 + AI 금지사항
└─ requirements.txt
```

## 실행

```bash
cd backend
python -m venv .venv
# Windows PowerShell
.venv\Scripts\Activate.ps1
# macOS/Linux
# source .venv/bin/activate

pip install -r requirements.txt
copy .env.example .env   # 값 채우기 (Gemini 필수, Pinecone 선택)
uvicorn app.main:app --reload --port 8000
```

- `GET /health` 로 키 설정 여부 확인.
- Pinecone 키가 없으면 RAG 는 로컬 저장소의 최근 경험으로 폴백합니다(개발용).

## 주요 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET/POST | `/experiences` | 경험 목록/저장(저장 시 임베딩 upsert) |
| GET/DELETE | `/experiences/{id}` | 단건 조회/삭제 |
| GET/POST | `/spec-items`, `/portfolio-projects`, `/application-records` | 보조 엔티티 CRUD |
| GET/POST | `/master-essays`, `/essay-versions` | 자소서/버전 저장 |
| POST | `/chat` | RAG 채팅 (SSE, `data: {"t": "..."}` / `data: {"done": true}`) |
| POST | `/essay/draft`, `/essay/full-review` | 문항 초안/전체 첨삭 (SSE) |

## 배포

### 백엔드 (Render / Railway / Fly.io 등)

- 저장소의 `backend/` 를 서비스 루트로 배포합니다.
- 컨테이너: 포함된 `Dockerfile` 사용, 또는 buildpack: `Procfile` 사용.
- 환경 변수(대시보드에서 주입): `GOOGLE_API_KEY`, `PINECONE_API_KEY`, `PINECONE_INDEX`,
  `PINECONE_CLOUD`, `PINECONE_REGION`, `CORS_ORIGINS`(배포된 웹 도메인), 필요 시 `DATABASE_URL`.
- 헬스체크 경로: `/health`.
- SQLite 는 단일 인스턴스/개발용입니다. 다중 인스턴스로 확장하면 `DATABASE_URL` 을 외부
  Postgres 로 교체하세요(문서 저장소 스키마는 그대로 사용 가능).

### 프론트엔드 (Flutter Web)

배포된 백엔드 URL 을 빌드 타임에 주입합니다.

```bash
flutter build web --dart-define=API_BASE_URL=https://your-backend.example.com
```

- 산출물 `build/web/` 를 정적 호스팅(Netlify, Vercel, Firebase Hosting, S3 등)합니다.
- 백엔드 `CORS_ORIGINS` 에 이 웹 도메인을 반드시 추가하세요.
- 로컬 개발: 백엔드 `uvicorn app.main:app --reload` + `flutter run -d chrome`
  (기본 `API_BASE_URL` 은 `http://localhost:8000`).

## RAG 개요

1. 경험 저장 시 STAR 필드를 임베딩해 Pinecone 에 `user_id` 네임스페이스로 upsert.
2. 마스터 자소서/포트폴리오 생성 시 쿼리(사용자 메시지 + 지원 직무)를 임베딩해 top-k 검색.
3. 선택한 경험(exact) + 검색된 경험(discovered)을 프롬프트에 주입해 Gemini 호출.
