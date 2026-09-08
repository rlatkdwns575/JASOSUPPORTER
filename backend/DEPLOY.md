# JasoSupporter 배포 체크리스트

FastAPI 백엔드를 프로덕션에 올릴 때 확인할 항목입니다.

## 필수 환경 변수

| 변수 | 프로덕션 권장 |
|------|----------------|
| `LLM_PROVIDER` | `ollama` |
| `OLLAMA_MODEL` | `jaso-coach` |
| `OLLAMA_BASE_URL` | Ollama 엔드포인트 |
| `JWT_SECRET` | 32자 이상 랜덤 문자열 (기본값 금지) |
| `AUTH_REQUIRED` | `true` |
| `DATABASE_URL` | `postgresql+psycopg://...` |
| `CORS_ORIGINS` | 실제 웹/앱 도메인 (쉼표 구분, `*` 금지) |

## 로컬 LLM (Ollama)

```bash
# 학습·create 는 jasosupporter-ml 참고
ollama create jaso-coach -f jasosupporter-ml/ollama/Modelfile
```

`backend/.env`:

```env
LLM_PROVIDER=ollama
OLLAMA_MODEL=jaso-coach
```

## 배포 순서 (예시)

```bash
cd backend
docker compose up -d          # Postgres
cp .env.example .env          # 값 채우기
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## 헬스 확인

```bash
curl http://localhost:8000/health
```

확인 필드: `llmProvider`, `ollamaConfigured`, `localModel`, `authRequired`, `jwtSecretConfigured`

## Flutter 클라이언트

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

- `AUTH_REQUIRED=true`이면 앱 **설정 → 로그인** 필수
- API Key는 클라이언트에 두지 않음

## 보안

- `.env`는 절대 Git에 커밋하지 않음
- JWT_SECRET 기본값으로 배포 금지
