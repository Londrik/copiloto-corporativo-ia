# Guia de Operação e Desenvolvimento Local (Runbook)

Este manual descreve o ciclo de vida operacional, configuração de ambiente e resolução de falhas no monorepo corporativo.

---

## 1. Pré-Requisitos do Ambiente (Fedora Linux)
- Rust Toolchain: rustc, cargo, rustfmt, clippy (1.80+).
- Go Runtime: go (1.23+).
- Python: python3 (3.12+), ruff, mypy, pytest.
- Google Cloud SDK: gcloud, gsutil autenticados.

---

## 2. Comandos Operacionais por Serviço

### 2.1. Sanitizador Nativo (Rust FFI)
- Verificação de estilo: cargo fmt --check (em services/pii-sanitizer)
- Lint estrito: cargo clippy --no-default-features -- -D warnings
- Testes unitários: cargo test --no-default-features

### 2.2. Orquestrador de IA (FastAPI Core)
- Linter e formato: ruff check . && ruff format --check . (em services/core-api)
- Checagem estática: mypy .
- Testes assíncronos: pytest -v

### 2.3. Motor Assíncrono de Relatórios (Go Asynq Worker)
- Verificação estática: go vet ./... (em workers/pdf-engine)
- Testes de concorrência: go test -v -race ./...

---

## 3. Matriz de Troubleshooting Rápido

| Sintoma | Causa Raiz | Ação Corretiva |
| :--- | :--- | :--- |
| ModuleNotFoundError: No module named 'main' | Diretório raiz fora do sys.path | Configurar pythonpath = ["."] no pyproject.toml |
| Source file found twice under different module names | Mypy sem pacotes explícitos | Ativar explicit_package_bases e mypy_path |
| error: no such command: fmt | rustfmt ausente no Fedora | Instalar com sudo dnf install -y rustfmt |
| Commit direto na branch 'main' e proibido | Git Guard ativo | Trabalhar em branch feature/* derivada de develop |
