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

// FetchSessionResponses fetches all responses with their question data for a session.
func (s *SupabaseStore) FetchSessionResponses(sessionID string) ([]model.ResponseWithQuestion, error) {
	query := `
		SELECT r.id, r.audio_file_path, r.processing_order,
		       q.question_text, q.part_number, q.question_order
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
			&r.ResponseID, &r.AudioFilePath, &r.ProcessingOrder,
			&r.QuestionText, &r.PartNumber, &r.QuestionOrder,
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

// DownloadAudio downloads an audio file from Supabase Storage.
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

// CheckSessionStatus returns the current status of a test session.
func (s *SupabaseStore) CheckSessionStatus(sessionID string) (string, error) {
	var status string
	err := s.db.QueryRow("SELECT status FROM test_sessions WHERE id = $1", sessionID).Scan(&status)
	if err != nil {
		return "", fmt.Errorf("failed to check session status: %w", err)
	}
	return status, nil
}
