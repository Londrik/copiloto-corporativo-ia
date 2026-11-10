# ADR-002: Orquestrador FastAPI com Vertex AI e Zero Data Retention (ZDR)

## 1. Metadados
* **Status:** Aceito
* **Data:** 2026-11-10
* **Autores:** Henry Cardoso
* **Componentes Afetados:** `services/core-api`

---

## 2. Contexto e Declaração do Problema
O sistema precisa orquestrar requisições empresariais de IA conectando regras de negócio, dados relacionais e geração de relatórios. O envio de dados corporativos a modelos externos exige garantia contratual de privacidade e imunidade a injeções de prompt ou vazamento de credenciais.

---

## 3. Decisão Técnica
1. Adotar **FastAPI 0.115+** com **Python 3.12** e validação estrita com **Pydantic v2** (`extra="forbid"`, `frozen=True`).
2. Utilizar o SDK corporativo do **Google Cloud Vertex AI** apontado para `gemini-2.0-flash`.
3. Ativar políticas de **Zero Data Retention (ZDR)** para assegurar que nenhum prompt seja persistido para treinamento de modelos do Google.
4. Delimitar prompts untrusted via tags XML padronizadas (`<Instrucoes-Seguras>`, `<Contexto-Dados>`).
5. Usar **Function Calling exclusivo** para mapear intenções e argumentos, impedindo execução direta de código arbitrário (`eval`) ou manipulação não autorizada de SQL.

---

## 4. Consequências e Trade-offs
### 4.1. Impactos Positivos
* Conformidade total com a LGPD e governança corporativa de IA.
* Schemas de entrada e saída auditáveis em tempo de compilação/execução (`mypy --strict`).
* Latência reduzida usando `gemini-2.0-flash` para triagem e dispatching de workers.

### 4.2. Custos e Limitações Aceitas
* Exige credenciais da GCP vinculadas à Service Account `sa-core-api`.
* A latência da chamada externa depende do SLA de inferência do Vertex AI.

---

## 5. Alternativas Consideradas e Rejeitadas
* **Google AI Studio (Gemini Developer API):** Rejeitado por ausência de SLA corporativo e suporte direto a IAM/ZDR granular.
* **LangChain/LlamaIndex:** Rejeitados devido à complexidade desnecessária, dependências excessivas e superfícies ocultas de segurança.

---

## 6. Revisão de Segurança e Compliance
* **OWASP LLM01 (Prompt Injection):** Isolamento com tags XML estritas e validação via Pydantic v2.
* **OWASP LLM06 (Sensitive Information Disclosure):** Chamada prévia mandatória ao motor nativo `pii-sanitizer` em Rust.
* **IAM Least Privilege:** Permissão restrita via papel `roles/aiplatform.user`.
