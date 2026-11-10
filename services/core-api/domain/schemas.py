"""Contratos de dados e DTOs com validação estrita Pydantic v2.

Aplica model_config com extra='forbid' e frozen=True em payloads sensíveis.
"""

from enum import StrEnum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class UserRole(StrEnum):
    """Papéis de usuário permitidos para controle de acesso (RBAC)."""

    ADMIN = "admin"
    ANALYST = "analyst"
    VIEWER = "viewer"


class PromptExecutionRequestDTO(BaseModel):
    """DTO de entrada para submissão de comandos e prompts ao copiloto.

    Attributes:
        prompt: Conteúdo textual não confiável submetido pelo usuário.
        user_role: Papel de acesso do solicitante para validação RBAC.
        session_id: Identificador de sessão de atendimento.
    """

    model_config = ConfigDict(extra="forbid", frozen=True)

    prompt: str = Field(
        min_length=3, max_length=4000, description="Texto não sanitizado do usuário"
    )
    user_role: UserRole = Field(description="Papel do usuário requisitante")
    session_id: str = Field(
        min_length=8, max_length=64, description="ID único da sessão corporativa"
    )


class FunctionCallArgumentsDTO(BaseModel):
    """Parâmetros extraídos da chamada de função executada pelo modelo."""

    model_config = ConfigDict(extra="forbid", frozen=True)

    action: str = Field(description="Nome da ação técnica solicitada")
    parameters: dict[str, Any] = Field(
        default_factory=dict, description="Parâmetros estruturados da ação"
    )


class PromptExecutionResponseDTO(BaseModel):
    """DTO de resposta estruturada entregue ao cliente.

    Attributes:
        sanitized_prompt: Texto com dados sensíveis (CPF/CNPJ) mascarados.
        intent_classified: Ação corporativa mapeada via Vertex AI.
        dispatch_status: Status de envio para a fila de execução assíncrona.
        trace_id: ID de rastreamento para auditoria no Cloud Logging.
    """

    model_config = ConfigDict(extra="forbid", frozen=True)

    sanitized_prompt: str
    intent_classified: str
    dispatch_status: str
    trace_id: str
