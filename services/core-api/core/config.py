"""Módulo de configurações e variáveis de ambiente validadas.

Segue as diretrizes do Google Python Style Guide e padrões Pydantic v2.
"""

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configurações globais da aplicação.

    Attributes:
        app_name: Identificador do microsserviço.
        environment: Ambiente de execução (staging, prod, test).
        gcp_project_id: ID do projeto GCP para chamadas Vertex AI.
        gcp_location: Região do Vertex AI com ZDR habilitado.
        redis_url: Endpoint de conexão para fila Asynq do worker Go.
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "copiloto-core-api"
    environment: str = Field(default="staging", pattern=r"^(development|staging|production|test)$")
    gcp_project_id: str = Field(default="corp-ai-reports-prod")
    gcp_location: str = Field(default="southamerica-east1")
    redis_url: str = Field(default="redis://localhost:6379/0")


@lru_cache
def get_settings() -> Settings:
    """Retorna uma instância singleton com as configurações validadas.

    Returns:
        Instância de Settings em cache.
    """
    return Settings()
