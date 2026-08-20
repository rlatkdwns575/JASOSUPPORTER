# JasoSupporter 로컬 LLM 학습 (QLoRA SFT)

앱 runtime(`requirements.txt`)과 분리된 학습 파이프라인입니다.

## 요구 사항

| 항목 | 권장 |
|------|------|
| GPU VRAM | 12GB+ (QLoRA 4bit, 7B) |
| 베이스 모델 | `Qwen/Qwen2.5-7B-Instruct` |
| 추론 | [Ollama](https://ollama.com) |

## 1. 학습 의존성 설치

**Windows:** `requirements-train.txt` 주석은 ASCII만 사용 (pip cp949 오류 방지).

```bash
cd backend
python -m venv .venv-train
.venv-train\Scripts\activate   # Windows
pip install -r training/requirements-train.txt
```

CUDA GPU가 있으면 [pytorch.org](https://pytorch.org/get-started/locally/)에서 `torch` 설치 명령을 확인하세요.

**Windows 참고:** `bitsandbytes`(4bit QLoRA)는 Linux/WSL 권장. Windows에서는 `train_qlora.py`가 자동으로 **fp16/bf16 LoRA**로 폴백합니다 (VRAM 16GB+).

## 2. SFT 데이터셋 생성

essay eval fixture에서 fact/expansion 게이트를 통과한 샘플만 JSONL로 내보냅니다.

```bash
python -m training.export_sft_dataset
# → training/datasets/jaso_coach_sft.jsonl
```

수동으로 JSONL에 행을 추가할 때는 `eval/essay_fact_checker` + `eval/essay_expansion_scorer`로 검증하세요.

## 3. QLoRA 학습

```bash
python -m training.train_qlora
# → training/outputs/jaso-coach-lora/
```

옵션:

```bash
python -m training.train_qlora --epochs 5 --max-seq-length 4096
```

## 4. Ollama 모델 패키징

```bash
ollama pull qwen2.5:7b-instruct
cd training/ollama
ollama create jaso-coach -f Modelfile
```

LoRA adapter가 없으면 베이스 모델만으로도 동작합니다 (`ADAPTER` 줄을 주석 처리).

## 5. 백엔드 연동

`backend/.env`:

```env
LLM_PROVIDER=ollama
OLLAMA_MODEL=jaso-coach
CLOUD_AI_ENABLED=true   # 첨부 파일 시 Gemini 폴백
```

## 6. Live eval

```bash
python -m eval.essay_generation_live_eval --provider ollama
# 리포트: eval/reports/essay_live_ollama_latest.json
```

Judge(LLM-as-judge)는 Gemini API가 필요합니다.

## 디렉터리

```
training/
  datasets/jaso_coach_sft.jsonl   # 시드 JSONL (git)
  outputs/                        # adapter (gitignore)
  ollama/Modelfile
  export_sft_dataset.py
  train_qlora.py
```
