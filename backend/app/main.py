"""JasoSupporter FastAPI 앱 진입점."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import get_settings
from .db import init_db
from .logging_config import get_logger, setup_logging
from .middleware_observability import ObservabilityMiddleware
from .routers import auth, career, chat, chat_rooms, essay, experiences


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    setup_logging(settings.log_level)
    logger = get_logger(__name__)
    logger.info(
        "startup gemini=%s pinecone=%s auth_required=%s embedding_model=%s embedding_dim=%s",
        settings.gemini_enabled,
        settings.pinecone_enabled,
        settings.auth_required,
        settings.embedding_model,
        settings.embedding_dimension,
    )
    init_db()
    yield


app = FastAPI(title="JasoSupporter API", version="1.1.0", lifespan=lifespan)

_settings = get_settings()
app.add_middleware(ObservabilityMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=_settings.cors_origin_list or ["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(experiences.router)
app.include_router(career.router)
app.include_router(chat.router)
app.include_router(chat_rooms.router)
app.include_router(essay.router)


@app.get("/health", tags=["meta"])
def health() -> dict:
    return {
        "status": "ok",
        "gemini": _settings.gemini_enabled,
        "pinecone": _settings.pinecone_enabled,
        "authRequired": _settings.auth_required,
        "embeddingModel": _settings.embedding_model,
        "embeddingDimension": _settings.embedding_dimension,
        "genaiSdk": "google-genai",
    }
