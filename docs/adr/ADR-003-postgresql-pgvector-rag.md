# ADR-003: Persistência Relacional e Indexação Vetorial com PostgreSQL 16 e pgvector

## 1. Metadados
* **Status:** Aceito
* **Data:** 2026-11-10
* **Autores:** Henry Cardoso
* **Componentes Afetados:** `services/core-api`, `database/migrations`

---

## 2. Contexto e Declaração do Problema
O copiloto corporativo necessita armazenar sessões de auditoria, históricos de prompts sanitizados e metadados de relatórios gerados. Adicionalmente, para viabilizar busca semântica em base de conhecimento corporativa (RAG) sem introduzir bancos vetoriais dedicados complexos (ex: Pinecone, Milvus), precisamos de um mecanismo unificado que suporte transações ACID e consultas por similaridade de cosseno.

---

## 3. Decisão Técnica
1. Adotar **PostgreSQL 16** como banco primário unificado.
2. Ativar a extensão **pgvector** (`vector`) para armazenamento de embeddings de 768 dimensões (compatível com `text-embedding-004` do Vertex AI).
3. Utilizar índice **HNSW (Hierarchical Navigable Small World)** via `vector_cosine_ops` para balancear latência de busca e precisão sem custo excessivo de rebuild.
4. Manter controle de migrações em SQL puro numerado para execução determinística sem lockfiles proprietários de ORMs.

---

## 4. Consequências e Trade-offs
### 4.1. Impactos Positivos
* Zero custo de rede entre banco relacional e banco vetorial; joins diretos entre dados estruturados (relatórios) e embeddings.
* Transacionalidade estrita (ACID) na criação de tarefas e logs de auditoria.
* Facilidade de execução local via container Docker/Podman e paridade com Cloud SQL no GCP.

### 4.2. Custos e Limitações Aceitas
* Índices HNSW demandam consumo de memória RAM proporcional ao número de vetores (`maintenance_work_mem`).
* Necessita de PostgreSQL 16 compilado com os binários do `pgvector`.

---

## 5. Alternativas Consideradas e Rejeitadas
* **Pinecone / Weaviate:** Rejeitados por elevar a complexidade operacional, custo recorrente desnecessário e violar a soberania de dados on-premise/VPC.
* **Qdrant:** Rejeitado no estágio atual para evitar manter dois bancos distintos (Postgres para ACID e Qdrant para vetores).

---

## 6. Revisão de Segurança e Compliance
* **LGPD / Isolamento:** Os textos indexados no vetor passam previamente pelo `pii-sanitizer` em Rust. Dados como CPFs crus nunca são convertidos em embeddings.
* **RBAC:** Acesso granular via credenciais de aplicação (`copiloto_app`) com privilégios restritos (`NO SUPERUSER`).
