# JasoSupporter 배포 체크리스트

FastAPI 백엔드를 프로덕션에 올릴 때 확인할 항목입니다.

## 필수 환경 변수

| 변수 | 프로덕션 권장 |
|------|----------------|
| `GOOGLE_API_KEY` | Gemini 생성·임베딩용 실키 |
| `JWT_SECRET` | 32자 이상 랜덤 문자열 (기본값 금지) |
| `AUTH_REQUIRED` | `true` |
| `DATABASE_URL` | `postgresql+psycopg://...` |
| `CORS_ORIGINS` | 실제 웹/앱 도메인 (쉼표 구분, `*` 금지) |
| `EMBEDDING_DIMENSION` | Pinecone 인덱스 차원과 **동일** |

## 선택

| 변수 | 설명 |
|------|------|
| `PINECONE_API_KEY` | RAG 벡터 검색 (없으면 로컬 폴백) |
| `LOG_LEVEL` | `INFO` 또는 `WARNING` |
| `RAG_TOP_K` | 기본 `5` |

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

확인 필드:

- `gemini`: API 키 설정 여부
- `pinecone` / `pineconeDimensionMismatch`: 벡터 DB 상태
- `authRequired`: JWT 필수 여부
- `jwtSecretConfigured`: JWT_SECRET이 기본값이 아닌지
- `embeddingDimension`: Pinecone과 일치하는지

## Flutter 클라이언트

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

- `AUTH_REQUIRED=true`이면 앱 **설정 → 로그인** 필수
- API Key는 클라이언트에 두지 않음

## 보안

- `.env`는 절대 Git에 커mit하지 않음
- `JWT_SECRET` 기본값(`dev-change-me-jaso-supporter`) 사용 금지
- 프로덕션에서 `X-User-Id` soft identity는 `AUTH_REQUIRED=false`일 때만 허용
