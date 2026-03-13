package handler

import (
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/hibiken/asynq"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/storage"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/worker"
)

// UploadHandler handles pre-signed URL generation and upload completion for R2.
type UploadHandler struct {
	r2          *storage.R2Client
	store       *storage.SupabaseStore
	asynqClient *asynq.Client
	secret      string
}

// NewUploadHandler creates a new UploadHandler.
func NewUploadHandler(r2 *storage.R2Client, store *storage.SupabaseStore, asynqClient *asynq.Client, secret string) *UploadHandler {
	return &UploadHandler{
		r2:          r2,
		store:       store,
		asynqClient: asynqClient,
		secret:      secret,
	}
}

// GenerateUploadURL handles POST /generate-upload-url.
// Returns a pre-signed PUT URL for direct iOS-to-R2 upload.
func (h *UploadHandler) GenerateUploadURL(w http.ResponseWriter, r *http.Request) {
	if !authenticate(r, h.secret) {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	var req model.PresignedURLRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request body"})
		return
	}

	if req.UserID == "" || req.TestID == "" || req.PartType == "" || req.QuestionID == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "user_id, test_id, part_type, and question_id are required"})
		return
	}

	// Enforce quota
	allowed, err := h.store.CheckUserQuota(req.UserID)
	if err != nil {
		slog.Error("failed to check user quota", "user_id", req.UserID, "error", err)
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "quota check failed"})
		return
	}
	if !allowed {
		writeJSON(w, http.StatusForbidden, model.QuotaResponse{
			Allowed: false,
			Message: "monthly test limit reached, upgrade your plan for more tests",
		})
		return
	}

	// Build R2 object key
	ext := ".wav"
	if req.FileExtension != "" {
		ext = req.FileExtension
	}
	r2Key := fmt.Sprintf("users/%s/%s/%s/%s%s", req.UserID, req.TestID, req.PartType, req.QuestionID, ext)

	uploadURL, err := h.r2.GenerateUploadURL(r.Context(), r2Key, 12*time.Hour)
	if err != nil {
		slog.Error("failed to generate pre-signed upload URL", "error", err)
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to generate upload URL"})
		return
	}

	slog.Info("generated upload URL", "r2_key", r2Key, "user_id", req.UserID)

	writeJSON(w, http.StatusOK, model.PresignedURLResponse{
		UploadURL: uploadURL,
		R2Key:     r2Key,
		ExpiresIn: int((12 * time.Hour).Seconds()),
	})
}

// UploadComplete handles POST /upload-complete.
// Called after iOS successfully uploads audio to R2. Updates DB and optionally queues evaluation.
func (h *UploadHandler) UploadComplete(w http.ResponseWriter, r *http.Request) {
	if !authenticate(r, h.secret) {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	var req model.UploadCompleteRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "invalid request body"})
		return
	}

	if req.R2Key == "" || req.TestSessionID == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "r2_key and test_session_id are required"})
		return
	}

	// Update response with R2 key if response_id is provided
	if req.ResponseID != "" {
		if err := h.store.UpdateResponseR2Key(req.ResponseID, req.R2Key); err != nil {
			slog.Error("failed to update response r2_key", "response_id", req.ResponseID, "error", err)
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to update response"})
			return
		}
	}

	// If this is the final upload (all_responses_uploaded flag), trigger evaluation
	if req.TriggerEvaluation {
		task, err := worker.NewEvaluateSessionTask(req.TestSessionID, req.UserID, req.TemplateID)
		if err != nil {
			slog.Error("failed to create evaluation task", "error", err)
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to create evaluation task"})
			return
		}

		info, err := h.asynqClient.Enqueue(task)
		if err != nil {
			slog.Error("failed to enqueue evaluation task", "error", err)
			writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to enqueue evaluation"})
			return
		}

		slog.Info("evaluation triggered from upload-complete",
			"session_id", req.TestSessionID,
			"task_id", info.ID,
		)

		writeJSON(w, http.StatusOK, map[string]interface{}{
			"status":              "ok",
			"evaluation_queued":   true,
			"task_id":             info.ID,
		})
		return
	}

	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

// GetQuota handles GET /quota?user_id=...
func (h *UploadHandler) GetQuota(w http.ResponseWriter, r *http.Request) {
	if !authenticate(r, h.secret) {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		writeJSON(w, http.StatusBadRequest, map[string]string{"error": "user_id is required"})
		return
	}

	sub, err := h.store.GetUserSubscription(userID)
	if err != nil {
		slog.Error("failed to get subscription", "user_id", userID, "error", err)
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to get subscription"})
		return
	}

	writeJSON(w, http.StatusOK, model.QuotaResponse{
		Allowed:   sub.TestsUsedThisMonth < sub.TestsPerMonth,
		Tier:      sub.Tier,
		Used:      sub.TestsUsedThisMonth,
		Limit:     sub.TestsPerMonth,
		Remaining: sub.TestsPerMonth - sub.TestsUsedThisMonth,
	})
}
