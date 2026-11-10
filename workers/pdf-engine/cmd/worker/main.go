package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/Londrik/copiloto-corporativo-ia/workers/pdf-engine/internal/model"
	"github.com/Londrik/copiloto-corporativo-ia/workers/pdf-engine/internal/pdf"
	"github.com/hibiken/asynq"
)

const (
	TypeReportGenerate = "report:generate"
	DefaultQueue       = "reports"
)

func handleReportTask(ctx context.Context, t *asynq.Task) error {
	var payload model.ReportTaskPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("falha ao deserializar payload da tarefa: %w", err)
	}

	log.Printf("[Worker] Processando relatorio %s para titular %s", payload.ReportID, payload.CustomerCPF)

	pdfBytes, err := pdf.GenerateReportPDF(ctx, &payload)
	if err != nil {
		return fmt.Errorf("falha na geracao de PDF: %w", err)
	}

	log.Printf("[Worker] PDF compilado com sucesso (%d bytes). Pronto para streaming em bucket.", len(pdfBytes))
	return nil
}

func main() {
	redisAddr := os.Getenv("REDIS_ADDR")
	if redisAddr == "" {
		redisAddr = "127.0.0.1:6379"
	}

	srv := asynq.NewServer(
		asynq.RedisClientOpt{Addr: redisAddr},
		asynq.Config{
			Concurrency: 5,
			Queues: map[string]int{
				DefaultQueue: 1,
			},
			ShutdownTimeout: 10 * time.Second,
		},
	)

	mux := asynq.NewServeMux()
	mux.HandleFunc(TypeReportGenerate, handleReportTask)

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		<-sigChan
		log.Println("[Worker] Sinal de encerramento recebido. Drenando conexoes ativas...")
		srv.Shutdown()
	}()

	log.Printf("[Worker] Inicializando engine assincrona em %s (concorrencia: 5)...", redisAddr)
	if err := srv.Run(mux); err != nil {
		log.Fatalf("[Worker] Erro fatal no executor de tarefas: %v", err)
	}
}
