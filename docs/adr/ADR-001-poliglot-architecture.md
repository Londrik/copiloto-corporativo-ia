# ADR-001: Arquitetura Poliglota para Sanitização, Orquestração e Relatórios

## Status
Aceito

## Contexto
O processamento de relatórios corporativos contendo dados sensíveis (LGPD) exige alta taxa de transferência, conformidade estrita de privacidade contra vazamento de PII em LLMs e geração determinística de documentos sem concorrência bloqueante no backend web.

## Decisão
1. **Rust FFI (PyO3)** para regex e sanitização em tempo linear com DFA, desacoplado do garbage collector.
2. **FastAPI (Python 3.12)** como API Gateway de IA corporativa devido ao ecossistema nativo Vertex AI SDK e Pydantic v2.
3. **Go (Asynq/Maroto v2)** para processamento assíncrono de PDFs, isolando o uso intensivo de CPU da API REST.

## Consequências
- Exigência de toolchains de compilação cruzada (Maturin, Go compiler, Cargo) no CI/CD.
- Isolamento estrito de falhas: se a compilação de PDF falhar ou degradar memória, o endpoint da API permanece responsivo.
