#!/usr/bin/env bash
set -euo pipefail

# Variáveis Operacionais (Ajuste conforme sua organização)
PROJECT_ID="${GCP_PROJECT_ID:-corp-ai-reports-prod}"
REGION="${GCP_REGION:-southamerica-east1}"
SA_API_NAME="sa-core-api"
SA_WORKER_NAME="sa-pdf-worker"
BUCKET_REPORTS="bkt-${PROJECT_ID}-reports-ephemeral"
AR_REPO="corp-ai-containers"

echo "==> 1. Configurando projeto ativo: ${PROJECT_ID}"
gcloud config set project "${PROJECT_ID}"

echo "==> 2. Habilitando APIs essenciais (Princípio do menor blast-radius)"
gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    aiplatform.googleapis.com \
    storage.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    logging.googleapis.com \
    monitoring.googleapis.com

echo "==> 3. Criando Artifact Registry seguro para imagens de contêiner"
if ! gcloud artifacts repositories describe "${AR_REPO}" --location="${REGION}" >/dev/null 2>&1; then
    gcloud artifacts repositories create "${AR_REPO}" \
        --repository-format=docker \
        --location="${REGION}" \
        --description="Repositorio seguro de containers corporativos"
fi

echo "==> 4. Provisionando Cloud Storage para relatórios (TTL 7 dias)"
if ! gsutil ls -b "gs://${BUCKET_REPORTS}" >/dev/null 2>&1; then
    gsutil mb -p "${PROJECT_ID}" -c STANDARD -l "${REGION}" -b on "gs://${BUCKET_REPORTS}"
    
    # Política de ciclo de vida para auto-remoção de relatórios efêmeros
    cat << 'LIFECYCLE' > /tmp/gcs_lifecycle.json
{
  "rule": [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 7}
    }
  ]
}
LIFECYCLE
    gsutil lifecycle set /tmp/gcs_lifecycle.json "gs://${BUCKET_REPORTS}"
    rm -f /tmp/gcs_lifecycle.json
fi

echo "==> 5. Provisionando Service Accounts e IAM com Princípio do Menor Privilégio"
# Service Account Core API
if ! gcloud iam service-accounts describe "${SA_API_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" >/dev/null 2>&1; then
    gcloud iam service-accounts create "${SA_API_NAME}" \
        --display-name="Service Account para API Gateway FastAPI e Vertex AI"
fi

# Permissões da API (Apenas invocador Vertex AI e leitor de configurações)
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_API_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/aiplatform.user" --condition=None

# Service Account PDF Worker
if ! gcloud iam service-accounts describe "${SA_WORKER_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" >/dev/null 2>&1; then
    gcloud iam service-accounts create "${SA_WORKER_NAME}" \
        --display-name="Service Account para Worker de PDF e Storage"
fi

# Permissões do Worker (Criador de objetos no bucket restrito)
gsutil iam ch "serviceAccount:${SA_WORKER_NAME}@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin" "gs://${BUCKET_REPORTS}"

echo "==> Provisionamento base de infraestrutura GCP finalizado com sucesso."
