package pdf

import (
	"context"
	"fmt"

	"github.com/Londrik/copiloto-corporativo-ia/workers/pdf-engine/internal/model"
	"github.com/johnfercher/maroto/v2"
	"github.com/johnfercher/maroto/v2/pkg/components/text"
	"github.com/johnfercher/maroto/v2/pkg/config"
	"github.com/johnfercher/maroto/v2/pkg/consts/align"
	"github.com/johnfercher/maroto/v2/pkg/consts/fontstyle"
	"github.com/johnfercher/maroto/v2/pkg/props"
)

// GenerateReportPDF compila os dados do relatório em bytes com alocação determinística.
func GenerateReportPDF(ctx context.Context, data *model.ReportTaskPayload) ([]byte, error) {
	if err := ctx.Err(); err != nil {
		return nil, fmt.Errorf("contexto cancelado antes da geração do pdf: %w", err)
	}

	cfg := config.NewBuilder().
		WithMargins(15, 15, 15).
		Build()

	m := maroto.New(cfg)

	// Cabeçalho institucional corporativo
	m.AddRows(
		text.NewRow(12, "RELATÓRIO FINANCEIRO CORPORATIVO SEGURO", props.Text{
			Top:   2,
			Style: fontstyle.Bold,
			Align: align.Center,
			Size:  14,
		}),
		text.NewRow(8, fmt.Sprintf("ID do Relatório: %s", data.ReportID), props.Text{
			Top:   1,
			Style: fontstyle.Italic,
			Size:  9,
		}),
		text.NewRow(8, fmt.Sprintf("Titular (LGPD Mascarado): %s", data.CustomerCPF), props.Text{
			Top:   1,
			Style: fontstyle.Normal,
			Size:  10,
		}),
		text.NewRow(8, fmt.Sprintf("Valor Consolidado: R$ %.2f", data.TotalAmount), props.Text{
			Top:   1,
			Style: fontstyle.Bold,
			Size:  10,
		}),
		text.NewRow(14, fmt.Sprintf("Resumo da Análise: %s", data.Summary), props.Text{
			Top:   2,
			Style: fontstyle.Normal,
			Size:  9,
		}),
	)

	doc, err := m.Generate()
	if err != nil {
		return nil, fmt.Errorf("falha ao compilar pdf via maroto v2: %w", err)
	}

	return doc.GetBytes(), nil
}
