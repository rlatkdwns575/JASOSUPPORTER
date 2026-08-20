"""QLoRA SFT for JasoSupporter career coach (로컬 GPU).

사용:
  cd backend
  python -m venv .venv-train
  .venv-train\\Scripts\\activate
  pip install -r training/requirements-train.txt
  python -m training.export_sft_dataset
  python -m training.train_qlora
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

DATASET_PATH = Path(__file__).parent / "datasets" / "jaso_coach_sft.jsonl"
OUTPUT_DIR = Path(__file__).parent / "outputs" / "jaso-coach-lora"


def _load_model(base_model: str):
    import torch
    from peft import LoraConfig, get_peft_model
    from transformers import AutoModelForCausalLM, AutoTokenizer

    tokenizer = AutoTokenizer.from_pretrained(base_model, trust_remote_code=True)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    model_kwargs: dict = {"trust_remote_code": True}
    use_4bit = False

    try:
        from transformers import BitsAndBytesConfig

        import bitsandbytes  # noqa: F401

        model_kwargs["quantization_config"] = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.bfloat16,
            bnb_4bit_use_double_quant=True,
        )
        model_kwargs["device_map"] = "auto"
        use_4bit = True
        print("Using 4-bit QLoRA (bitsandbytes).")
    except ImportError:
        if not torch.cuda.is_available():
            print(
                "CUDA GPU가 없고 bitsandbytes도 설치되지 않았습니다.\n"
                "Linux/WSL + NVIDIA GPU 환경에서 학습하거나, "
                "pip install -r training/requirements-train.txt 로 의존성을 설치하세요."
            )
            return None, None
        dtype = torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
        model_kwargs["torch_dtype"] = dtype
        model_kwargs["device_map"] = "auto"
        print(f"bitsandbytes 없음 — fp16/bf16 LoRA로 학습합니다 ({dtype}). VRAM 16GB+ 권장.")

    model = AutoModelForCausalLM.from_pretrained(base_model, **model_kwargs)

    lora = LoraConfig(
        r=32,
        lora_alpha=32,
        lora_dropout=0.05,
        bias="none",
        task_type="CAUSAL_LM",
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj", "gate_proj", "up_proj", "down_proj"],
    )
    model = get_peft_model(model, lora)
    if use_4bit:
        model.print_trainable_parameters()
    return model, tokenizer


def main() -> int:
    parser = argparse.ArgumentParser(description="Train QLoRA adapter for jaso-coach")
    parser.add_argument("--base-model", default="Qwen/Qwen2.5-7B-Instruct")
    parser.add_argument("--dataset", default=str(DATASET_PATH))
    parser.add_argument("--output", default=str(OUTPUT_DIR))
    parser.add_argument("--epochs", type=int, default=3)
    parser.add_argument("--lr", type=float, default=2e-4)
    parser.add_argument("--max-seq-length", type=int, default=2048)
    args = parser.parse_args()

    try:
        import torch
        from datasets import load_dataset
        from trl import SFTConfig, SFTTrainer
    except ImportError as error:
        print(
            "학습 패키지가 없습니다. backend 폴더에서 다음을 실행하세요:\n"
            "  python -m venv .venv-train\n"
            "  .venv-train\\Scripts\\activate\n"
            "  pip install -r training/requirements-train.txt"
        )
        print(f"상세: {error}")
        return 1

    dataset_path = Path(args.dataset)
    if not dataset_path.exists():
        print(f"Dataset not found: {dataset_path}. Run python -m training.export_sft_dataset first.")
        return 1

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    model, tokenizer = _load_model(args.base_model)
    if model is None or tokenizer is None:
        return 1

    dataset = load_dataset("json", data_files=str(dataset_path), split="train")

    def format_row(row: dict) -> dict:
        messages = row["messages"]
        text = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=False)
        return {"text": text}

    dataset = dataset.map(format_row)

    training_args = SFTConfig(
        output_dir=str(output_dir),
        num_train_epochs=args.epochs,
        per_device_train_batch_size=1,
        gradient_accumulation_steps=8,
        learning_rate=args.lr,
        logging_steps=5,
        save_strategy="epoch",
        max_seq_length=args.max_seq_length,
        bf16=torch.cuda.is_available() and torch.cuda.is_bf16_supported(),
        fp16=torch.cuda.is_available() and not torch.cuda.is_bf16_supported(),
        report_to="none",
    )

    trainer = SFTTrainer(
        model=model,
        args=training_args,
        train_dataset=dataset,
        processing_class=tokenizer,
    )
    trainer.train()
    trainer.save_model(str(output_dir))
    tokenizer.save_pretrained(str(output_dir))
    print(f"Adapter saved to {output_dir}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
