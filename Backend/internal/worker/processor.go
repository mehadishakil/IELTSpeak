package worker

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	"github.com/hibiken/asynq"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/service"
)

type Processor struct {
	evaluator *service.Evaluator
}

func NewProcessor(evaluator *service.Evaluator) *Processor {
	return &Processor{evaluator: evaluator}
}

// HandleEvaluateSession processes a session evaluation task from the Redis queue.
func (p *Processor) HandleEvaluateSession(ctx context.Context, t *asynq.Task) error {
	var payload EvaluateSessionPayload
	if err := json.Unmarshal(t.Payload(), &payload); err != nil {
		return fmt.Errorf("failed to unmarshal payload: %w", err)
	}

	slog.Info("starting session evaluation",
		"session_id", payload.SessionID,
		"user_id", payload.UserID,
		"task_id", t.ResultWriter().TaskID(),
	)

	if err := p.evaluator.EvaluateSession(ctx, payload.SessionID, payload.UserID); err != nil {
		slog.Error("session evaluation failed",
			"session_id", payload.SessionID,
			"error", err,
		)
		return err
	}

	slog.Info("session evaluation completed", "session_id", payload.SessionID)
	return nil
}
