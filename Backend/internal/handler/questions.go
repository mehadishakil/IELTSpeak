package handler

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/mehadishakil/ieltspeak-evaluator/internal/storage"
)

// QuestionsHandler handles question-related endpoints.
type QuestionsHandler struct {
	r2     *storage.R2Client
	store  *storage.SupabaseStore
	secret string
}

// NewQuestionsHandler creates a new QuestionsHandler.
func NewQuestionsHandler(r2 *storage.R2Client, store *storage.SupabaseStore, secret string) *QuestionsHandler {
	return &QuestionsHandler{
		r2:     r2,
		store:  store,
		secret: secret,
	}
}

// TestQuestionsResponse is the response for GET /test-questions.
type TestQuestionsResponse struct {
	Questions []QuestionWithAudioURL `json:"questions"`
}

// QuestionWithAudioURL is a question with a pre-signed R2 download URL for audio.
type QuestionWithAudioURL struct {
	ID             string `json:"id"`
	TestTemplateID string `json:"test_template_id"`
	PartNumber     int    `json:"part_number"`
	QuestionOrder  int    `json:"question_order"`
	QuestionText   string `json:"question_text"`
	AudioURL       string `json:"audio_url"`       // Pre-signed R2 download URL
	Transcript     string `json:"transcript,omitempty"`
}

// GetTestQuestions handles GET /test-questions?template_id=...
// Returns questions with pre-signed R2 audio download URLs.
func (h *QuestionsHandler) GetTestQuestions(w http.ResponseWriter, r *http.Request) {
	if !authenticate(r, h.secret) {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "unauthorized"})
		return
	}

	templateID := r.URL.Query().Get("template_id")
	if templateID == "" {
		templateID = "550e8400-e29b-41d4-a716-446655440000" // default template
	}

	// Fetch questions from DB
	questions, err := h.store.FetchTestQuestions(templateID)
	if err != nil {
		slog.Error("failed to fetch test questions", "template_id", templateID, "error", err)
		writeJSON(w, http.StatusInternalServerError, map[string]string{"error": "failed to fetch questions"})
		return
	}

	// Generate pre-signed download URLs for each question's audio
	var result []QuestionWithAudioURL
	for _, q := range questions {
		audioURL := ""

		// Prefer R2 key if available
		if q.R2AudioKey != "" && h.r2 != nil {
			url, err := h.r2.GenerateDownloadURL(r.Context(), q.R2AudioKey, 1*time.Hour)
			if err != nil {
				slog.Warn("failed to generate R2 download URL", "question_id", q.ID, "r2_key", q.R2AudioKey, "error", err)
			} else {
				audioURL = url
			}
		}

		// If no R2 URL, fall back to constructing Supabase Storage URL
		if audioURL == "" && q.AudioFileURL != "" {
			audioURL = h.store.GetStoragePublicURL("audio-question-set", q.AudioFileURL)
		}

		result = append(result, QuestionWithAudioURL{
			ID:             q.ID,
			TestTemplateID: q.TestTemplateID,
			PartNumber:     q.PartNumber,
			QuestionOrder:  q.QuestionOrder,
			QuestionText:   q.QuestionText,
			AudioURL:       audioURL,
			Transcript:     q.Transcript,
		})
	}

	writeJSON(w, http.StatusOK, TestQuestionsResponse{Questions: result})
}
