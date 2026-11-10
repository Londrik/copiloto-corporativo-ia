# Sistema Corporativo de IA e Relatórios Seguros

## 1. Topologia do Sistema
Arquitetura desacoplada baseada em microsserviços e workers:
- **core-api (FastAPI 0.115+ / Python 3.12)**: Orquestrador assíncrono, validação Pydantic v2 e integração Google Vertex AI com Zero Data Retention (ZDR).
- **pii-sanitizer (Rust 1.80+ / PyO3)**: Extensão CPython FFI para mascaramento linear O(n) ReDoS-proof de CPF/CNPJ via autômato finito sem alocação no heap Python.
- **pdf-engine (Go 1.23+ / Asynq)**: Worker assíncrono distribuído via Redis para compilação determinística de relatórios (Maroto v2) e entrega efêmera via S3 presigned URLs.

## 2. Princípios de Segurança e Governança
- **OWASP LLM Compliance**: Prevenção ativa contra injeção indireta e vazamento de PII.
- **Princípio do Menor Privilégio (PoLP)**: Contas de serviço dedicadas com papéis restritos na GCP.
- **Hermeticidade e Reprodutibilidade**: Imagens de container multi-stage com digest SHA-256 e execução não-root (UID 10001).
