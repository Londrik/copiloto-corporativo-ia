-- Migração 001: Inicialização do schema corporativo e ativação de pgvector
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- Tabela de auditoria de sessões e prompts sanitizados
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id VARCHAR(64) NOT NULL,
    user_role VARCHAR(32) NOT NULL,
    sanitized_prompt TEXT NOT NULL,
    intent_classified VARCHAR(64) NOT NULL,
    trace_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_session_id ON audit_logs(session_id);
CREATE INDEX IF NOT EXISTS idx_audit_trace_id ON audit_logs(trace_id);

-- Tabela de documentos e chunks indexados para RAG
CREATE TABLE IF NOT EXISTS corporate_knowledge_vectors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_title VARCHAR(255) NOT NULL,
    content_chunk TEXT NOT NULL,
    embedding vector(768) NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índice HNSW com distância de cosseno para busca aproximada de vizinhos
CREATE INDEX IF NOT EXISTS idx_corporate_knowledge_hnsw 
ON corporate_knowledge_vectors 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Tabela de controle de relatórios gerados pelo worker Go
CREATE TABLE IF NOT EXISTS report_dispatches (
    report_id VARCHAR(64) PRIMARY KEY,
    session_id VARCHAR(64) NOT NULL,
    customer_cpf_masked VARCHAR(32) NOT NULL,
    total_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    storage_url TEXT,
    dispatch_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_report_status ON report_dispatches(dispatch_status);
