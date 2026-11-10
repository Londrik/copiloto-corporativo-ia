# Diagrama de Arquitetura e Fluxo

```mermaid
flowchart TD
    subgraph ClientLayer["Camada de Entrada"]
        ClientReq["Cliente / Webhook WhatsApp"]
    end

    subgraph IngressGateway["Edge & Ingress (GCP)"]
        CloudRunIngress["Cloud Run: core-api (FastAPI 0.115+)"]
    end

    subgraph NativeSecurityEngine["Motor Nativo de Segurança (FFI)"]
        RustFFI["pii-sanitizer (Rust 1.82 / PyO3)<br/>• DFA ReDoS-proof Regex<br/>• Máscara PII: ***.XXX.XXX-**"]
    end

    subgraph AIOrchestrator["Orquestração de Inteligência"]
        VertexAI["Google Vertex AI: Gemini 2.0 Flash<br/>• Zero Data Retention (ZDR)<br/>• Function Calling Dispatcher"]
    end

    subgraph DataPersistenceLayer["Camada Transacional & Vetorial"]
        PostgresDB[("PostgreSQL 16 + pgvector<br/>• Consultas Híbridas RRF<br/>• RBAC / Row-Level Locks")]
        RedisQueue[("Redis Ephemeral Engine<br/>• Asynq Task Queue")]
    end

    subgraph WorkerProcessingLayer["Processamento em Background"]
        GoWorker["Worker PDF (Go 1.23)<br/>• Maroto v2 Deterministic Engine<br/>• Bounded Goroutines (errgroup)"]
        GCSStorage["Cloud Storage (Bucket)<br/>• TTL 7 Dias<br/>• Presigned URL (15 min)"]
    end

    ClientReq -->|"HTTP POST /report"| CloudRunIngress
    CloudRunIngress -->|"1. String Slice (&str)"| RustFFI
    RustFFI -->|"2. Texto Sanitizado"| CloudRunIngress
    CloudRunIngress -->|"3. Intent & Args"| VertexAI
    VertexAI -->|"4. Function Execution"| CloudRunIngress
    CloudRunIngress -->|"5. Leitura SQL Segura"| PostgresDB
    CloudRunIngress -->|"6. Enfileira Task"| RedisQueue
    RedisQueue -->|"7. Consumo Concorrente"| GoWorker
    GoWorker -->|"8. Upload Stream"| GCSStorage
    GoWorker -.->|"9. Presigned GET URL"| ClientReq

