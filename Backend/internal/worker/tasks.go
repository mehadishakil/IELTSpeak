package worker

import (
	"encoding/json"
	"time"

	"github.com/hibiken/asynq"
)

const TypeEvaluateSession = "session:evaluate"

type EvaluateSessionPayload struct {
	SessionID  string `json:"session_id"`
	UserID     string `json:"user_id"`
	TemplateID string `json:"template_id"`
}

// NewEvaluateSessionTask creates a new Asynq task for session evaluation.
func NewEvaluateSessionTask(sessionID, userID, templateID string) (*asynq.Task, error) {
	payload, err := json.Marshal(EvaluateSessionPayload{
		SessionID:  sessionID,
		UserID:     userID,
		TemplateID: templateID,
	})
	if err != nil {
		return nil, err
	}

	return asynq.NewTask(
		TypeEvaluateSession,
		payload,
		asynq.MaxRetry(3),
		asynq.Timeout(5*time.Minute),
		asynq.Unique(30*time.Minute),
		asynq.Queue("evaluation"),
	), nil
}
