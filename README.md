# JasoSupporter

취업 준비생이 경험·스펙을 구조화하고 마스터 자소서·포트폴리오·면접·지원 기록으로 재사용하는 Flutter + FastAPI 워크스페이스입니다.

패키지 이름은 `chatgptmini`, 표시 이름은 **JasoSupporter**입니다. Gemini 키는 **서버에만** 둡니다.

## 아키텍처

```text
Flutter (Riverpod)
  → ApiClient (JWT Bearer 또는 soft X-User-Id + SSE)
  → FastAPI
       ├─ Auth (JWT register/login)
       ├─ SQLite / PostgreSQL (career_documents + auth_users + chat rooms)
       ├─ Gemini (google-genai: 생성·임베딩)
       └─ Pinecone (선택 RAG) + 키워드 rerank
```

| 구분 | 담당 |
|------|------|
| Gemini / Pinecone 키 | `backend/.env` |
| 시스템 프롬프트·RAG | 서버 |
| 커리어 데이터·채팅방 | 서버 DB |
| JWT 세션 | Flutter `AuthSession` (SharedPreferences) |
| Soft identity | 로그인 전 개발용 `X-User-Id` |

## 실행

### 백엔드

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env   # GOOGLE_API_KEY, JWT_SECRET 등
uvicorn app.main:app --reload --port 8000
```

Postgres(선택):

```bash
docker compose up -d
# .env: DATABASE_URL=postgresql+psycopg://jaso:jaso@localhost:5432/jaso_supporter
```

### Flutter

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

설정 화면에서 회원가입/로그인하면 JWT로 전환됩니다.

### 검증

로컬:

```bash
flutter analyze
flutter test
cd backend && pytest
python -m eval.rag_eval
python -m eval.generation_eval
```

`main` 브랜치 push/PR 시 GitHub Actions(`.github/workflows/ci.yml`)에서 Flutter analyze·test와 backend pytest·generation eval을 실행합니다.

## 주요 API

| 경로 | 설명 |
|------|------|
| `POST /auth/register`, `/auth/login`, `GET /auth/me` | JWT 인증 |
| `GET/POST/DELETE /experiences` | 경험 + 임베딩 upsert |
| career CRUD | spec / essay / portfolio / application / interview |
| `POST /chat` | AI SSE (공식) |
| `GET/POST/DELETE /chat-rooms` | 코치 대화 영속화 |
| `POST /essay/draft\|full-review` | `/chat` 편의 래퍼 |
| `GET /health`, `/models` | 헬스(embedding 차원·SDK)·모델 목록 |

`AUTH_REQUIRED=true`이면 Bearer 토큰이 필수입니다. 기본값은 `false`(개발 폴백).

## 제품 원칙

Experience → MasterEssay → PortfolioProject → InterviewAnswer → ApplicationRecord

AI는 사용자 사실만 사용하며 허위 수치·성과·역할을 만들지 않습니다.

## 라이선스

`publish_to: none`. ProductSans 배포 시 라이선스를 확인하세요.
