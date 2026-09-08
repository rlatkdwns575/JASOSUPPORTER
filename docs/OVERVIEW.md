# JasoSupporter 프로젝트 개요

## 한 줄 요약

사실 기반 경험 카드 → 마스터 자소서(Q1–Q6)를 **로컬 파인튜닝 LLM**으로 돕는 Flutter + FastAPI 앱과, 그 모델을 만드는 ML 레포.

## 레포 역할

| 레포 | 역할 |
|------|------|
| `JASOSUPPORTER` | 제품 UI/API. Ollama `jaso-coach`로 채팅·자소서 생성 |
| `jasosupporter-ml` | Gold 합성, QLoRA 학습, `ollama create jaso-coach` |

## 데이터·모델 흐름

1. (선택) Gold gen으로 Experience + SFT JSONL 축적  
2. QLoRA로 Qwen3-1.7B 어댑터 학습  
3. Ollama에 `jaso-coach`로 패키징  
4. 앱이 선택 경험 카드를 프롬프트에 넣고 `jaso-coach`에 스트리밍 요청  

## 제품 원칙

- Experience ≠ 자소서 초안 (사실만)
- Essay는 두괄식 5단, 카드에 없는 수치·역할 금지
- 클라우드 생성 LLM(Gemini 등)은 제품 경로에서 사용하지 않음
