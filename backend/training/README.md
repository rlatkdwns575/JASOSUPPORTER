# Training moved to the sibling repo jasosupporter-ml
#
#   cd ../jasosupporter-ml
#   python -m sft.train_qlora --config configs/qlora_baseline.yaml
#   cd ollama && ollama create jaso-coach -f Modelfile
#
# Then set backend/.env:
#   LLM_PROVIDER=ollama
#   OLLAMA_MODEL=jaso-coach
