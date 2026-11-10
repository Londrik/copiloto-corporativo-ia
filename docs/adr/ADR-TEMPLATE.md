# ADR-XXX: [Título Sucinto da Decisão]

## 1. Metadados
* **Status:** [Proposto | Aceito | Substituído por ADR-YYY]
* **Data:** AAAA-MM-DD
* **Autores:** [Nome do Engenheiro]
* **Componentes Afetados:** [`services/core-api`, `workers/pdf-engine`, etc.]

---

## 2. Contexto e Declaração do Problema
Descreva a motivação técnica e de negócio. Qual é o gargalo, risco de segurança ou restrição operacional que motiva esta decisão?

---

## 3. Decisão Técnica
Detalhe a solução adotada de maneira clara e técnica:
* Tecnologias, bibliotecas e versões pinadas.
* Topologia de execução e contratos de comunicação.
* Restrições de implementação aplicadas.

---

## 4. Consequências e Trade-offs
### 4.1. Impactos Positivos
* O que se ganha em performance, determinismo, segurança ou escalabilidade?

### 4.2. Custos e Limitações Aceitas
* Quais restrições operacionais adicionais são introduzidas?

---

## 5. Alternativas Consideradas e Rejeitadas
* **Alternativa 1:** [Descrição] — *Motivo da rejeição*: [Argumento técnico].
* **Alternativa 2:** [Descrição] — *Motivo da rejeição*: [Argumento técnico].

---

## 6. Revisão de Segurança e Compliance
* **OWASP / ASI Impact:** [Ex: OWASP LLM01 - Prompt Injection Mitigation].
* **LGPD / PII Isolation:** [Como dados pessoais são tratados/mascarados].
* **Princípio do Menor Privilégio (GCP IAM):** [Papéis restritos necessários].
