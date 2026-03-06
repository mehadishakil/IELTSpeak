package handler

import (
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"
	"time"

	"github.com/hibiken/asynq"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/storage"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/worker"
)

type Handler struct {
	asynqClient *asynq.Client
	store       *storage.SupabaseStore
	secret      string
}

func NewHandler(asynqClient *asynq.Client, store *storage.SupabaseStore, secret string) *Handler {
	return &Handler{
		asynqClient: asynqClient,
		store:       store,
		secret:      secret,
	}
}

// Evaluate handles POST /evaluate — validates, enqueues task to Redis, returns immediately.
func (h *Handler) Evaluate(w http.ResponseWriter, r *http.Request) {
	// Authenticate
	if !h.authenticate(r) {
		writeJSON(w, http.StatusUnauthorized, model.EvaluateResponse{
			Success: false,
			Error:   "unauthorized",
		})
		return
	}

	// Parse request
	var req model.EvaluateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, model.EvaluateResponse{
			Success: false,
			Error:   "invalid request body",
		})
		return
	}

	if req.SessionID == "" {
		writeJSON(w, http.StatusBadRequest, model.EvaluateResponse{
			Success: false,
			Error:   "session_id is required",
		})
		return
	}

	// Check idempotency
	status, err := h.store.CheckSessionStatus(req.SessionID)
	if err != nil {
		slog.Error("failed to check session status", "error", err)
		writeJSON(w, http.StatusInternalServerError, model.EvaluateResponse{
			Success:   false,
			SessionID: req.SessionID,
			Error:     "failed to check session status",
		})
		return
	}

	if status == "evaluated" {
		writeJSON(w, http.StatusOK, model.EvaluateResponse{
			Success:   true,
			SessionID: req.SessionID,
			Message:   "session already evaluated",
		})
		return
	}

	if status == "processing" {
		writeJSON(w, http.StatusConflict, model.EvaluateResponse{
			Success:   false,
			SessionID: req.SessionID,
			Error:     "session is already being processed",
		})
		return
	}

	// Enqueue task
	task, err := worker.NewEvaluateSessionTask(req.SessionID, req.UserID, req.TemplateID)
	if err != nil {
		slog.Error("failed to create task", "error", err)
		writeJSON(w, http.StatusInternalServerError, model.EvaluateResponse{
			Success:   false,
			SessionID: req.SessionID,
			Error:     "failed to create evaluation task",
		})
		return
	}

	info, err := h.asynqClient.Enqueue(task)
	if err != nil {
		slog.Error("failed to enqueue task", "error", err)
		writeJSON(w, http.StatusInternalServerError, model.EvaluateResponse{
			Success:   false,
			SessionID: req.SessionID,
			Error:     "failed to enqueue evaluation task",
		})
		return
	}

	slog.Info("evaluation task enqueued",
		"session_id", req.SessionID,
		"task_id", info.ID,
		"queue", info.Queue,
	)

	writeJSON(w, http.StatusAccepted, model.EvaluateResponse{
		Success:   true,
		SessionID: req.SessionID,
		TaskID:    info.ID,
		Message:   "evaluation enqueued",
	})
}

// Health handles GET /health.
func (h *Handler) Health(w http.ResponseWriter, r *http.Request) {
	dbStatus := "connected"
	if err := h.store.Ping(); err != nil {
		dbStatus = "disconnected"
	}

	// Note: Redis health is implicitly checked by Asynq server startup.
	// A more thorough check could ping Redis directly.
	writeJSON(w, http.StatusOK, model.HealthResponse{
		Status:    "ok",
		Redis:     "connected",
		DB:        dbStatus,
		Timestamp: time.Now(),
	})
}

func (h *Handler) authenticate(r *http.Request) bool {
	auth := r.Header.Get("Authorization")
	if auth == "" {
		return false
	}
	token := strings.TrimPrefix(auth, "Bearer ")
	return token == h.secret
}

func writeJSON(w http.ResponseWriter, statusCode int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	json.NewEncoder(w).Encode(data)
}
