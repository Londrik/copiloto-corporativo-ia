# Padrões Oficiais de Engenharia e Documentação

Este documento estabelece as diretrizes normativas de arquitetura, documentação de código e tomada de decisão técnica do ecossistema, orientadas pelas práticas da Google Engineering e do Google Cloud Platform (GCP).

---

## 1. Google Design Docs & Architecture Decision Records (ADRs)
Todas as decisões estruturais com impacto em mais de um serviço, mudanças de contrato ou adoção de tecnologia devem ser formalizadas via ADR em `docs/adr/`.

* **Nomenclatura:** `ADR-XXX-<slug-descritivo>.md` (ex: `ADR-002-fastapi-vertex-ai-zdr.md`).
* **Ciclo de Vida:** `Proposto` -> `Em Revisão` -> `Aceito` | `Substituído` | `Rejeitado`.
* **Seções Obrigatórias:**
  1. **Contexto & Problema**: Limitações técnicas e requisitos de negócio.
  2. **Decisão**: Ação técnica definitiva com diagramação de suporte.
  3. **Consequências**: Trade-offs positivos e restrições/débitos aceitos.
  4. **Alternativas Rejeitadas**: Por que outras soluções foram descartadas.
  5. **Análise de Segurança**: Avaliação de conformidade (OWASP LLM, PoLP, LGPD).

---

## 2. Docstrings e Código (Google Python Style Guide)
Todo módulo, classe, função e rota HTTP no FastAPI deve conter docstring completa no formato Google:

* **Sintaxe Obrigatória:**
  ```python
  def process_sanitized_input(
      payload: ExecutionContextDTO,
      raw_text: str,
  ) -> SanitizedResultDTO:
      """Executa a sanitização em lote e valida restrições de RBAC.

      Args:
          payload: DTO validado contendo os metadados de sessão e autorização.
          raw_text: Conteúdo textual não confiável submetido pelo usuário.

      Returns:
          Instância de SanitizedResultDTO com textos mascarados e métricas.

      Raises:
          SecurityViolationError: Se for detectada tentativa de evasão de filtro.
          ValidationError: Se o payload violar o esquema do Pydantic v2.
      """

3. Contratos de API REST (Google API Design Guide)

    Estrutura de Rotas: Substantivos plurais com versionamento explícito (/v1/prompts/execute, /v1/reports).

    Envelope de Erro Canônico:
    JSON

    {
      "error": {
        "code": 403,
        "message": "Permissão negada para o recurso especificado.",
        "status": "PERMISSION_DENIED",
        "details": [
          {
            "reason": "INSUFFICIENT_ROLE",
            "domain": "iam.corp.internal"
          }
        ]
      }
    }

4. Rastreabilidade Git (Conventional Commits)

Commits devem seguir a estrutura <tipo>(<escopo>): <descrição no imperativo>:

    feat(api): Nova rota, DTO ou orquestrador.

    fix(sanitizer): Correção de falha de segurança ou parser de texto.

    docs(adr): Inclusão ou atualização de ADR.

    test(core): Cobertura de testes unitários ou de integração.

    chore(deps): Atualização de toolchains, bibliotecas ou flags.
