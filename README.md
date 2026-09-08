# JasoSupporter

취업 준비생이 경험·스펙을 구조화하고 마스터 자소서·포트폴리오·면접·지원 기록으로 재사용하는 Flutter + FastAPI 워크스페이스입니다.

패키지 이름은 `chatgptmini`, 표시 이름은 **JasoSupporter**입니다.  
AI 생성은 **로컬 Ollama 파인튜닝 모델 `jaso-coach`** 를 사용합니다 (Google Gemini 불필요).

학습·Gold 데이터는 형제 레포 [jasosupporter-ml](../jasosupporter-ml)에서 수행합니다.

## 프로젝트 개요

| 구분 | 내용 |
|------|------|
| Experience | 사실 창고 (STAR-like). 자소서 문장 아님 |
| Master Essay | Q1–Q6 두괄식 5단. 선택 경험 사실만 인용 |
| 추론 | FastAPI → Ollama `jaso-coach` (SSE) |
| 학습 | `jasosupporter-ml` QLoRA → `ollama create jaso-coach` |

## 아키텍처

```text
Flutter (Riverpod)
  → ApiClient (JWT Bearer 또는 soft X-User-Id + SSE)
  → FastAPI
       ├─ Auth (JWT register/login)
       ├─ SQLite / PostgreSQL (career_documents + auth_users + chat rooms)
       └─ Ollama (jaso-coach: 로컬 파인튜닝 자소서 코치)
```

| 구분 | 담당 |
|------|------|
| Ollama 모델 | 로컬 `jaso-coach` (ML 레포에서 학습·create) |
| 시스템 프롬프트·경험 컨텍스트 | 서버 (선택 경험 카드) |
| 커리어 데이터·채팅방 | 서버 DB |
| JWT 세션 | Flutter `AuthSession` (SharedPreferences) |

## 실행

### 0) Ollama + jaso-coach

```bash
# Ollama 설치 후
ollama serve
# 학습·create: jasosupporter-ml README 참고
ollama list   # jaso-coach 확인
```

CUDA 오류가 나면 CPU/Vulkan으로 `OLLAMA_HOST=127.0.0.1:11435 ollama serve` 후  
`backend/.env`의 `OLLAMA_BASE_URL=http://127.0.0.1:11435` 로 맞추세요.

### 1) 백엔드

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env   # LLM_PROVIDER=ollama, OLLAMA_MODEL=jaso-coach, JWT_SECRET
uvicorn app.main:app --reload --port 8000
```

Postgres(선택):

```bash
docker compose up -d
# .env: DATABASE_URL=postgresql+psycopg://jaso:jaso@localhost:5432/jaso_supporter
```

### 2) Flutter

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

설정 화면에서 회원가입/로그인하면 JWT로 전환됩니다.

### 검증

```bash
flutter analyze
flutter test
cd backend && pytest
python -m eval.generation_eval
```

`main` 브랜치 push/PR 시 GitHub Actions에서 Flutter analyze·test와 backend pytest를 실행합니다.

## 주요 API

| 경로 | 설명 |
|------|------|
| `POST /auth/register`, `/auth/login`, `GET /auth/me` | JWT 인증 |
| `GET/POST/DELETE /experiences` | 경험 CRUD (로컬 DB) |
| career CRUD | spec / essay / portfolio / application / interview |
| `POST /chat` | AI SSE (공식, Ollama) |
| `GET/POST/DELETE /chat-rooms` | 코치 대화 영속화 |
| `POST /essay/draft\|full-review` | `/chat` 편의 래퍼 |
| `GET /health`, `/models` | 헬스·Ollama 모델 목록 |

## 제품 원칙

Experience → MasterEssay → PortfolioProject → InterviewAnswer → ApplicationRecord

AI는 사용자 사실만 사용하며 허위 수치·성과·역할을 만들지 않습니다.

## 라이선스

`publish_to: none`. ProductSans 배포 시 라이선스를 확인하세요.
