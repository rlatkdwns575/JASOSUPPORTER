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
        "startup llm=ollama model=%s auth_required=%s",
        settings.ollama_model,
        settings.auth_required,
    )
    if settings.auth_required and settings.jwt_secret_is_default:
        logger.warning(
            "AUTH_REQUIRED=true but JWT_SECRET is default or too short; change JWT_SECRET before production"
        )
    if settings.auth_required and settings.cors_origin_list == ["*"]:
        logger.warning("AUTH_REQUIRED=true with CORS_ORIGINS=*; restrict origins in production")
    init_db()
    yield


app = FastAPI(title="JasoSupporter API", version="1.2.0", lifespan=lifespan)

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
        "gemini": False,
        "authRequired": _settings.auth_required,
        "jwtSecretConfigured": not _settings.jwt_secret_is_default,
        "genaiSdk": None,
        "llmProvider": "ollama",
        "ollamaConfigured": True,
        "cloudAiEnabled": False,
        "localModel": _settings.ollama_model,
    }
