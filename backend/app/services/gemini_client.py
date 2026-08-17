"""Google GenAI SDK 클라이언트 (공유)."""

from functools import lru_cache

from google import genai

from ..config import get_settings


@lru_cache
def get_genai_client() -> genai.Client | None:
    settings = get_settings()
    if not settings.gemini_enabled:
        return None
    return genai.Client(api_key=settings.google_api_key)
