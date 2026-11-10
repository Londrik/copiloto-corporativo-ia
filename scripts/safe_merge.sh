#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER="${1:-}"

if [ -z "${PR_NUMBER}" ]; then
    echo "Uso: ./scripts/safe_merge.sh <NUMERO_DO_PR>"
    exit 1
fi

echo "==> Verificando status dos checks no PR #${PR_NUMBER}..."

# Aguarda conclusão dos checks e valida se todos passaram
STATUS=$(gh pr checks "${PR_NUMBER}" || true)
echo "${STATUS}"

if echo "${STATUS}" | grep -E "(fail|error)"; then
    echo "ERRO [Quality Gate CI]: O PR #${PR_NUMBER} possui checks com falha! Merge BLOQUEADO."
    exit 1
fi

if echo "${STATUS}" | grep -E "(pending|in_progress)"; then
    echo "AVISO: Há jobs ainda em execução no CI. Aguarde a finalização antes de mergear."
    exit 1
fi

echo "==> Todos os checks do GitHub Actions passaram com sucesso!"
echo "Executando merge squash em develop..."
gh pr merge "${PR_NUMBER}" --squash --delete-branch

echo "==> PR #${PR_NUMBER} mergeado com sucesso!"
