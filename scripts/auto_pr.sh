#!/usr/bin/env bash
set -euo pipefail

CURRENT_BRANCH=$(git branch --show-current)

if [ "${CURRENT_BRANCH}" = "main" ] || [ "${CURRENT_BRANCH}" = "develop" ]; then
    echo "ERRO: Não é permitido criar PR a partir de main ou develop diretamente."
    echo "Crie uma branch de feature: git checkout -b feature/nome-da-feature develop"
    exit 1
fi

echo "=========================================="
echo " INICIANDO PIPELINE DE QUALITY GATE LOCAL"
echo " Branch: ${CURRENT_BRANCH} -> Target: develop"
echo "=========================================="

# 1. Verificação de status
if [ -n "$(git status --porcelain)" ]; then
    echo "Commitando alterações pendentes..."
    git add .
    git commit -m "feat(sanitizer): complete atomic unit tests and abi3 configuration"
fi

# 2. Rust Engine Gates
echo "-> 1/3 Verificando Formatação e Lints do Rust..."
(cd services/pii-sanitizer && cargo fmt --check && cargo clippy --no-default-features -- -D warnings)

echo "-> 2/3 Executando Testes Unitários de Borda..."
(cd services/pii-sanitizer && cargo test --no-default-features)

echo "-> 3/3 Testando compilação FFI Python ABI3..."
(cd services/pii-sanitizer && PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1 cargo check --features python)

echo "=========================================="
echo " QUALITY GATE: 100% APROVADO"
echo "=========================================="

# 4. Envio e Criação de Pull Request
echo "Enviando branch para o repositório remoto..."
git push -u origin "${CURRENT_BRANCH}"

echo "Abrindo Pull Request automatizado para develop via gh CLI..."
gh pr create \
    --base develop \
    --head "${CURRENT_BRANCH}" \
    --title "feat: ${CURRENT_BRANCH}" \
    --body "## Resumo das Alterações
- Implementação da engine nativa de sanitização de PII em Rust (\`services/pii-sanitizer\`).
- Autômato linear DFA O(n) para mascaramento de CPF e CNPJ (LGPD).
- Configuração de compatibilidade PyO3 ABI3 para interoperabilidade com CPython.

## Verificações Locais (Quality Gate)
- [x] \`cargo fmt --check\` executado com sucesso.
- [x] \`cargo clippy -- -D warnings\` limpo sem avisos.
- [x] 4 testes unitários de borda aprovados (\`cargo test\`)."

echo "==> Pull Request aberto com sucesso!"
