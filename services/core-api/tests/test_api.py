"""Testes de integração assíncronos da API e sanitização."""

import pytest
from httpx import ASGITransport, AsyncClient

from main import app


@pytest.mark.asyncio
async def test_health_check() -> None:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "HEALTHY"


@pytest.mark.asyncio
async def test_execute_prompt_with_pii_sanitization() -> None:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "prompt": "Gerar relatório para o cliente portador do CPF 123.456.789-00 urgente.",
            "user_role": "analyst",
            "session_id": "sess-test-corporate-uuid-1234",
        }
        response = await client.post("/v1/prompts/execute", json=payload)
        assert response.status_code == 200
        data = response.json()
        assert "123.456.789-00" not in data["sanitized_prompt"]
        assert "***.456.789-**" in data["sanitized_prompt"]
        assert data["intent_classified"] == "generate_financial_report"
        assert data["dispatch_status"] == "ENQUEUED"


@pytest.mark.asyncio
async def test_execute_prompt_rejects_extra_fields() -> None:
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "prompt": "Texto válido",
            "user_role": "analyst",
            "session_id": "sess-test-corporate-uuid-1234",
            "campo_malicioso_extra": "tentativa_injecao",
        }
        response = await client.post("/v1/prompts/execute", json=payload)
        assert response.status_code == 422
