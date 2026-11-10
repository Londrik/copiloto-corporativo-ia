"""Rotas HTTP para submissão e processamento de prompts."""

from fastapi import APIRouter, status

from domain.schemas import PromptExecutionRequestDTO, PromptExecutionResponseDTO
from services.orchestrator import CopilotOrchestrator

router = APIRouter(prefix="/v1/prompts", tags=["Prompts"])


@router.post(
    "/execute",
    response_model=PromptExecutionResponseDTO,
    status_code=status.HTTP_200_OK,
    summary="Submete prompt do usuário para sanitização e classificação de IA",
)
async def execute_prompt(
    payload: PromptExecutionRequestDTO,
) -> PromptExecutionResponseDTO:
    """Executa sanitização e análise com Vertex AI."""
    return await CopilotOrchestrator.process_request(payload)
