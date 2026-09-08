# JasoSupporter Eval

오프라인·라이브 eval 스크립트 모음.

## 스크립트

| 명령 | 용도 | CI |
|------|------|-----|
| `python -m eval.generation_eval` | 수치·기관 hallucination 휴리스틱 | O |
| `python -m eval.essay_eval` | 자소서 사실성 + 의미 확장 fixture eval | O |
| `python -m eval.rag_eval` | RAG hit@k (로컬 DB) | X (수동) |
| `python -m eval.essay_generation_live_eval` | Ollama 실호출 + 휴리스틱 | X (수동) |

## 2계층 평가 모델

### 사실 계층 (hard gate)

Experience STAR에 있는 것만 허용:

- 상황·과제·행동·결과·수치·기관·역할·기술 스택

구현: [`essay_fact_checker.py`](essay_fact_checker.py)

### 의미·표현 계층 (soft score)

사실 위에서 AI가 확장해야 하는 영역:

- 강점, 인사이트, 두괄식, 문항 적합성, 차별화

구현: [`essay_expansion_scorer.py`](essay_expansion_scorer.py)

## 오프라인 eval

```powershell
cd backend
python -m eval.essay_eval
```

Fixture: [`fixtures/essay_eval_cases.json`](fixtures/essay_eval_cases.json)

- `good_response`: 사실 faithful + 의미 확장
- `bad_fact_response`: 허위 사실 → fact checker FAIL 기대
- `bad_summary_response`: STAR 재서술 → expansion gate FAIL 기대

합격 기준 (CI):

- generation_eval 3/3 PASS
- essay fixture fact checker: good PASS / bad FAIL
- essay fixture expansion: good >= 0.35, bad_summary < gate

## Live eval (수동)

```powershell
cd backend
# Ollama + jaso-coach 실행 중이어야 함
python -m eval.essay_generation_live_eval
python -m eval.essay_generation_live_eval --require-ollama
```

옵션:

- `--require-ollama`: Ollama 연결 실패 시 exit 1
- `--cases path/to/fixtures.json`

흐름:

1. fixture Experience를 임시 SQLite에 seed
2. `prompt_builder` + 선택 경험 컨텍스트로 Ollama 초안 생성
3. 오프라인 fact/expansion 휴리스틱 검사

결과: [`reports/essay_live_ollama_latest.json`](reports/essay_live_ollama_latest.json)

## 프롬프트 정책

- 문서: [`docs/05_AI_POLICY.md`](../../docs/05_AI_POLICY.md)
- 서버 시스템 프롬프트: [`app/services/prompt_builder.py`](../app/services/prompt_builder.py) `MASTER_RESUME_SYSTEM`

프롬프트 수정 후 baseline 비교:

1. `python -m eval.essay_eval` (회귀 없음)
2. `python -m eval.essay_generation_live_eval` (live baseline 갱신)

## 주의

- live eval: **선택 경험 주입만** 사용 (벡터 DB 없음).
- expansion scorer는 proxy metric이다. live judge 결과와 주기적으로 calibration한다.
- `reports/`는 gitignore 대상으로 두는 것을 권장한다 (로컬 baseline용).
