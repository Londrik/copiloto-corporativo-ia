package pdf

import (
	"context"
	"testing"
	"time"

	"github.com/Londrik/copiloto-corporativo-ia/workers/pdf-engine/internal/model"
)

func TestGenerateReportPDF_Success(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	payload := &model.ReportTaskPayload{
		ReportID:    "rep-test-uuid-001",
		SessionID:   "sess-corp-999",
		UserRole:    "analyst",
		CustomerCPF: "***.456.789-**",
		TotalAmount: 14500.50,
		Summary:     "Auditoria financeira processada sem inconformidades.",
	}

	pdfBytes, err := GenerateReportPDF(ctx, payload)
	if err != nil {
		t.Fatalf("erro inesperado ao gerar PDF: %v", err)
	}

	if len(pdfBytes) == 0 {
		t.Fatal("esperado buffer de bytes nao vazio para o PDF")
	}

	// Validação de magic bytes do formato PDF (%PDF-)
	if string(pdfBytes[:5]) != "%PDF-" {
		t.Fatalf("cabecalho invalido de PDF, recebido: %s", string(pdfBytes[:5]))
	}
}

func TestGenerateReportPDF_ContextTimeout(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel() // Cancela imediatamente para simular timeout preemptivo

	payload := &model.ReportTaskPayload{
		ReportID: "rep-timeout-001",
	}

	_, err := GenerateReportPDF(ctx, payload)
	if err == nil {
		t.Fatal("esperado erro ao passar contexto previamente cancelado")
	}
}
