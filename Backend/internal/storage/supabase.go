package storage

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"

	_ "github.com/lib/pq"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
)

type SupabaseStore struct {
	db         *sql.DB
	storageURL string
	serviceKey string
	httpClient *http.Client
}

func NewSupabaseStore(databaseURL, supabaseURL, serviceKey string) (*SupabaseStore, error) {
	db, err := sql.Open("postgres", databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(5 * time.Minute)

	if err := db.Ping(); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	return &SupabaseStore{
		db:         db,
		storageURL: supabaseURL + "/storage/v1",
		serviceKey: serviceKey,
		httpClient: &http.Client{Timeout: 60 * time.Second},
	}, nil
}

func (s *SupabaseStore) Close() error {
	return s.db.Close()
}

func (s *SupabaseStore) Ping() error {
	return s.db.Ping()
}

// ==================== Response Queries ====================

// FetchSessionResponses fetches all responses with their question data for a session.
// Includes r2_key for R2 downloads.
func (s *SupabaseStore) FetchSessionResponses(sessionID string) ([]model.ResponseWithQuestion, error) {
	query := `
		SELECT r.id, COALESCE(r.audio_file_path, ''), COALESCE(r.r2_key, ''),
		       r.processing_order, q.question_text, q.part_number, q.question_order
		FROM responses r
		JOIN questions q ON r.question_id = q.id
		WHERE r.test_session_id = $1
		ORDER BY r.processing_order ASC
	`

	rows, err := s.db.Query(query, sessionID)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch responses: %w", err)
	}
	defer rows.Close()

	var results []model.ResponseWithQuestion
	for rows.Next() {
		var r model.ResponseWithQuestion
		if err := rows.Scan(
			&r.ResponseID, &r.AudioFilePath, &r.R2Key,
			&r.ProcessingOrder, &r.QuestionText, &r.PartNumber, &r.QuestionOrder,
		); err != nil {
			return nil, fmt.Errorf("failed to scan response row: %w", err)
		}
		results = append(results, r)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("row iteration error: %w", err)
	}

	return results, nil
}

// UpdateResponseR2Key sets the r2_key on a response after upload to R2.
func (s *SupabaseStore) UpdateResponseR2Key(responseID, r2Key string) error {
	query := `UPDATE responses SET r2_key = $2 WHERE id = $1`
	_, err := s.db.Exec(query, responseID, r2Key)
	if err != nil {
		return fmt.Errorf("failed to update response r2_key: %w", err)
	}
	return nil
}

// UpdateResponseScores updates individual response scores and feedback.
func (s *SupabaseStore) UpdateResponseScores(scores *model.ResponseScores) error {
	mistakesJSON, err := json.Marshal(scores.Mistakes)
	if err != nil {
		return fmt.Errorf("failed to marshal mistakes: %w", err)
	}

	query := `
		UPDATE responses SET
			transcript = $2,
			fluency_score = $3,
			pronunciation_score = $4,
			grammar_score = $5,
			vocabulary_score = $6,
			topic_relevance_score = $7,
			duration_seconds = $8,
			azure_response = $9,
			feedback = $10,
			mistakes = $11,
			is_processed = true,
			processing_status = 'completed',
			evaluated_at = NOW()
		WHERE id = $1
	`

	_, err = s.db.Exec(query,
		scores.ResponseID,
		scores.Transcript,
		scores.FluencyScore,
		scores.PronunciationScore,
		scores.GrammarScore,
		scores.VocabularyScore,
		scores.TopicRelevance,
		scores.DurationSeconds,
		scores.AzureResponse,
		scores.Feedback,
		mistakesJSON,
	)
	if err != nil {
		return fmt.Errorf("failed to update response scores: %w", err)
	}
	return nil
}

// MarkResponseFailed marks a response as failed with an error message.
func (s *SupabaseStore) MarkResponseFailed(responseID, errorMsg string) error {
	query := `UPDATE responses SET processing_status = 'failed', error_message = $2 WHERE id = $1`
	_, err := s.db.Exec(query, responseID, errorMsg)
	return err
}

// ==================== Session Queries ====================

// UpdateSessionStatus updates the test session status.
func (s *SupabaseStore) UpdateSessionStatus(sessionID, status string) error {
	query := `UPDATE test_sessions SET status = $2 WHERE id = $1`
	_, err := s.db.Exec(query, sessionID, status)
	if err != nil {
		return fmt.Errorf("failed to update session status: %w", err)
	}
	return nil
}

// UpdateSessionProcessingQueue updates the session processing queue status.
func (s *SupabaseStore) UpdateSessionProcessingQueue(sessionID, status string) error {
	query := `UPDATE session_processing_queue SET status = $2, updated_at = NOW() WHERE test_session_id = $1`
	_, err := s.db.Exec(query, sessionID, status)
	if err != nil {
		slog.Warn("failed to update session_processing_queue", "error", err, "session_id", sessionID)
	}
	return nil
}

// UpdateSessionScores updates the final aggregated session scores.
func (s *SupabaseStore) UpdateSessionScores(sessionID string, scores *model.SessionScores) error {
	overallFeedbackJSON, err := json.Marshal(scores.OverallFeedback)
	if err != nil {
		return fmt.Errorf("failed to marshal overall feedback: %w", err)
	}

	query := `
		UPDATE test_sessions SET
			overall_band_score = $2,
			fluency_score = $3,
			pronunciation_score = $4,
			grammar_score = $5,
			vocabulary_score = $6,
			topic_relevance_score = $7,
			overall_feedback = $8,
			status = 'evaluated',
			completed_at = NOW()
		WHERE id = $1
	`

	_, err = s.db.Exec(query,
		sessionID,
		scores.OverallBandScore,
		scores.FluencyScore,
		scores.PronunciationScore,
		scores.GrammarScore,
		scores.VocabularyScore,
		scores.TopicRelevance,
		overallFeedbackJSON,
	)
	if err != nil {
		return fmt.Errorf("failed to update session scores: %w", err)
	}
	return nil
}

// CheckSessionStatus returns the current status of a test session.
func (s *SupabaseStore) CheckSessionStatus(sessionID string) (string, error) {
	var status string
	err := s.db.QueryRow("SELECT status FROM test_sessions WHERE id = $1", sessionID).Scan(&status)
	if err != nil {
		return "", fmt.Errorf("failed to check session status: %w", err)
	}
	return status, nil
}

// ==================== Quota / Subscription Queries ====================

// CheckUserQuota returns true if the user has remaining tests this month.
// Auto-resets the counter if a new month has started.
func (s *SupabaseStore) CheckUserQuota(userID string) (bool, error) {
	sub, err := s.GetUserSubscription(userID)
	if err != nil {
		// If no subscription found, allow (graceful fallback)
		slog.Warn("no subscription found, allowing by default", "user_id", userID, "error", err)
		return true, nil
	}

	// Auto-reset if new month
	now := time.Now().UTC()
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.UTC)
	if sub.CurrentPeriodStart.Before(monthStart) {
		if err := s.resetMonthlyQuota(userID, monthStart); err != nil {
			slog.Warn("failed to reset monthly quota", "user_id", userID, "error", err)
		}
		return true, nil
	}

	return sub.TestsUsedThisMonth < sub.TestsPerMonth, nil
}

// GetUserSubscription fetches the user's subscription details.
func (s *SupabaseStore) GetUserSubscription(userID string) (*model.UserSubscription, error) {
	query := `
		SELECT id, user_id, tier, tests_per_month, tests_used_this_month, current_period_start
		FROM user_subscriptions WHERE user_id = $1
	`
	var sub model.UserSubscription
	err := s.db.QueryRow(query, userID).Scan(
		&sub.ID, &sub.UserID, &sub.Tier,
		&sub.TestsPerMonth, &sub.TestsUsedThisMonth, &sub.CurrentPeriodStart,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to get subscription: %w", err)
	}
	return &sub, nil
}

// IncrementUserTestCount increments the user's monthly test usage by 1.
func (s *SupabaseStore) IncrementUserTestCount(userID string) error {
	query := `
		UPDATE user_subscriptions
		SET tests_used_this_month = tests_used_this_month + 1, updated_at = NOW()
		WHERE user_id = $1
	`
	_, err := s.db.Exec(query, userID)
	if err != nil {
		return fmt.Errorf("failed to increment test count: %w", err)
	}
	return nil
}

func (s *SupabaseStore) resetMonthlyQuota(userID string, newPeriodStart time.Time) error {
	query := `
		UPDATE user_subscriptions
		SET tests_used_this_month = 0, current_period_start = $2, updated_at = NOW()
		WHERE user_id = $1
	`
	_, err := s.db.Exec(query, userID, newPeriodStart)
	return err
}

// ==================== Question Queries ====================

// QuestionRecord represents a row from the questions table.
type QuestionRecord struct {
	ID             string
	TestTemplateID string
	PartNumber     int
	QuestionOrder  int
	QuestionText   string
	AudioFileURL   string // Supabase Storage path (legacy)
	R2AudioKey     string // Cloudflare R2 key (preferred)
	Transcript     string
}

// FetchTestQuestions fetches all questions for a test template, ordered by part and question order.
func (s *SupabaseStore) FetchTestQuestions(templateID string) ([]QuestionRecord, error) {
	query := `
		SELECT id, test_template_id, part_number, question_order, question_text,
		       COALESCE(audio_file_url, '') AS audio_file_url,
		       COALESCE(r2_audio_key, '') AS r2_audio_key,
		       COALESCE(transcript, '') AS transcript
		FROM questions
		WHERE test_template_id = $1
		ORDER BY part_number ASC, question_order ASC
	`

	rows, err := s.db.Query(query, templateID)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch questions: %w", err)
	}
	defer rows.Close()

	var results []QuestionRecord
	for rows.Next() {
		var q QuestionRecord
		if err := rows.Scan(
			&q.ID, &q.TestTemplateID, &q.PartNumber, &q.QuestionOrder,
			&q.QuestionText, &q.AudioFileURL, &q.R2AudioKey, &q.Transcript,
		); err != nil {
			return nil, fmt.Errorf("failed to scan question row: %w", err)
		}
		results = append(results, q)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("row iteration error: %w", err)
	}

	return results, nil
}

// GetStoragePublicURL constructs a public URL for a Supabase Storage object.
func (s *SupabaseStore) GetStoragePublicURL(bucket, path string) string {
	return fmt.Sprintf("%s/object/public/%s/%s", s.storageURL, bucket, path)
}

// ==================== Supabase Storage (Legacy) ====================

// DownloadAudio downloads an audio file from Supabase Storage.
// Used as fallback when R2 key is not available.
func (s *SupabaseStore) DownloadAudio(filePath string) ([]byte, error) {
	url := fmt.Sprintf("%s/object/audio-responses/%s", s.storageURL, filePath)

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+s.serviceKey)

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to download audio: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("storage download failed (status %d): %s", resp.StatusCode, string(body))
	}

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read audio data: %w", err)
	}

	return data, nil
}
