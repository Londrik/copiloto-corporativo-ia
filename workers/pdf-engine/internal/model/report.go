package model

// ReportTaskPayload define a estrutura estrita deserializada da fila Asynq.
type ReportTaskPayload struct {
	ReportID    string  `json:"report_id"`
	SessionID   string  `json:"session_id"`
	UserRole    string  `json:"user_role"`
	CustomerCPF string  `json:"customer_cpf"`
	TotalAmount float64 `json:"total_amount"`
	Summary     string  `json:"summary"`
}

// GeneratedReportResult encapsula metadados da entrega efêmera.
type GeneratedReportResult struct {
	ReportID      string `json:"report_id"`
	PresignedURL  string `json:"presigned_url"`
	FileSizeBytes int    `json:"file_size_bytes"`
}
