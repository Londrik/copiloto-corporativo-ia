"""Ponto de entrada da aplicação FastAPI."""

from fastapi import FastAPI

from api.routes.prompts import router as prompts_router
from core.config import get_settings

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.include_router(prompts_router)


@app.get("/health", tags=["Health"])
async def health_check() -> dict[str, str]:
    """Sonda de prontidão e liveness para o Cloud Run."""
    return {"status": "HEALTHY", "environment": settings.environment}
