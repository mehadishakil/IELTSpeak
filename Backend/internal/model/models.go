package model

import (
	"encoding/json"
	"time"
)

// ==================== HTTP Request/Response Models ====================

// EvaluateRequest is the payload from the edge function or direct API call.
type EvaluateRequest struct {
	SessionID  string `json:"session_id"`
	UserID     string `json:"user_id"`
	TemplateID string `json:"template_id"`
}

// EvaluateResponse is returned by POST /evaluate.
type EvaluateResponse struct {
	Success   bool   `json:"success"`
	Message   string `json:"message"`
	SessionID string `json:"session_id"`
	TaskID    string `json:"task_id,omitempty"`
	Error     string `json:"error,omitempty"`
}

// PresignedURLRequest is the payload for POST /generate-upload-url.
type PresignedURLRequest struct {
	UserID        string `json:"user_id"`
	TestID        string `json:"test_id"`
	PartType      string `json:"part_type"`       // "part1", "part2", "part3"
	QuestionID    string `json:"question_id"`
	FileExtension string `json:"file_extension"`  // ".wav", ".m4a" (default ".wav")
}

// PresignedURLResponse is returned by POST /generate-upload-url.
type PresignedURLResponse struct {
	UploadURL string `json:"upload_url"`
	R2Key     string `json:"r2_key"`
	ExpiresIn int    `json:"expires_in"` // seconds
}

// UploadCompleteRequest notifies the backend that an upload finished.
type UploadCompleteRequest struct {
	ResponseID        string `json:"response_id"`
	R2Key             string `json:"r2_key"`
	TestSessionID     string `json:"test_session_id"`
	UserID            string `json:"user_id"`
	TemplateID        string `json:"template_id"`
	QuestionID        string `json:"question_id"`
	TriggerEvaluation bool   `json:"trigger_evaluation"` // true if this is the final upload
}

// QuotaResponse is returned by GET /quota and quota-check failures.
type QuotaResponse struct {
	Allowed   bool   `json:"allowed"`
	Tier      string `json:"tier,omitempty"`
	Used      int    `json:"used,omitempty"`
	Limit     int    `json:"limit,omitempty"`
	Remaining int    `json:"remaining,omitempty"`
	Message   string `json:"message,omitempty"`
}

// HealthResponse is returned by GET /health.
type HealthResponse struct {
	Status    string    `json:"status"`
	Redis     string    `json:"redis"`
	DB        string    `json:"db"`
	R2        string    `json:"r2"`
	Timestamp time.Time `json:"timestamp"`
}

// ==================== Database Models ====================

// ResponseWithQuestion is a joined row from responses + questions.
type ResponseWithQuestion struct {
	ResponseID      string
	AudioFilePath   string // Supabase Storage path (legacy)
	R2Key           string // Cloudflare R2 key (preferred)
	ProcessingOrder int
	QuestionText    string
	PartNumber      int
	QuestionOrder   int
}

// UserSubscription represents a user's subscription tier and quota.
type UserSubscription struct {
	ID                 string    `json:"id"`
	UserID             string    `json:"user_id"`
	Tier               string    `json:"tier"`
	TestsPerMonth      int       `json:"tests_per_month"`
	TestsUsedThisMonth int       `json:"tests_used_this_month"`
	CurrentPeriodStart time.Time `json:"current_period_start"`
}

// ==================== Azure Models ====================

// AzureResult holds parsed Azure Pronunciation Assessment output.
type AzureResult struct {
	Transcript        string          `json:"transcript"`
	AccuracyScore     float64         `json:"accuracy_score"`
	FluencyScore      float64         `json:"fluency_score"`
	CompletenessScore float64         `json:"completeness_score"`
	ProsodyScore      float64         `json:"prosody_score"`
	PronScore         float64         `json:"pron_score"`
	DurationSeconds   int             `json:"duration_seconds"`
	Words             []WordDetail    `json:"words"`
	RawResponse       json.RawMessage `json:"raw_response"`
}

// WordDetail holds word-level pronunciation info from Azure.
type WordDetail struct {
	Word          string  `json:"word"`
	AccuracyScore float64 `json:"accuracy_score"`
	ErrorType     string  `json:"error_type"` // None, Omission, Insertion, Mispronunciation
}

// ==================== GPT Models ====================

// GPTBatchedResult is the structured response from a single batched GPT call
// that evaluates ALL responses and provides overall feedback.
type GPTBatchedResult struct {
	Responses []GPTBatchedResponseResult `json:"responses"`
	Overall   GPTOverallResult           `json:"overall"`
}

// GPTBatchedResponseResult is per-response scoring from the batched GPT call.
type GPTBatchedResponseResult struct {
	QuestionIndex         int       `json:"question_index"`
	FluencyCoherenceScore float64   `json:"fluency_coherence_score"`
	LexicalResourceScore  float64   `json:"lexical_resource_score"`
	GrammaticalRangeScore float64   `json:"grammatical_range_score"`
	TopicRelevanceScore   float64   `json:"topic_relevance_score"`
	Mistakes              []Mistake `json:"mistakes"`
	Feedback              string    `json:"feedback"`
}

// GPTQuestionResult is the structured JSON output from GPT per question (individual call fallback).
type GPTQuestionResult struct {
	FluencyCoherenceScore float64   `json:"fluency_coherence_score"`
	LexicalResourceScore  float64   `json:"lexical_resource_score"`
	GrammaticalRangeScore float64   `json:"grammatical_range_score"`
	TopicRelevanceScore   float64   `json:"topic_relevance_score"`
	Mistakes              []Mistake `json:"mistakes"`
	Feedback              string    `json:"feedback"`
}

// Mistake represents a grammar or vocabulary error in the transcript.
type Mistake struct {
	Original   string `json:"original"`
	Correction string `json:"correction"`
	Type       string `json:"type"`       // "grammar" or "vocabulary"
	Category   string `json:"category"`   // "tense", "article", "word_choice", etc.
	StartIndex int    `json:"start_index"`
	EndIndex   int    `json:"end_index"`
}

// GPTOverallResult is the structured JSON output for overall test feedback.
type GPTOverallResult struct {
	OverallFeedback string   `json:"overall_feedback"`
	Strengths       []string `json:"strengths"`
	Improvements    []string `json:"improvements"`
	Tips            []string `json:"tips"`
}

// ==================== Score Models ====================

// ResponseScores holds the final combined scores for a single response.
type ResponseScores struct {
	ResponseID         string
	Transcript         string
	FluencyScore       float64
	PronunciationScore float64
	GrammarScore       float64
	VocabularyScore    float64
	TopicRelevance     float64
	DurationSeconds    int
	Feedback           string
	Mistakes           []Mistake
	AzureResponse      json.RawMessage
}

// SessionScores holds the aggregated scores for the entire test session.
type SessionScores struct {
	OverallBandScore   float64
	FluencyScore       float64
	PronunciationScore float64
	GrammarScore       float64
	VocabularyScore    float64
	TopicRelevance     float64
	OverallFeedback    *GPTOverallResult
}

// AzureProcessedResponse holds Azure results for a response before GPT evaluation.
type AzureProcessedResponse struct {
	ResponseIndex int
	Response      ResponseWithQuestion
	AzureResult   *AzureResult
	WavPath       string // temp WAV path (for cleanup)
	M4aPath       string // temp M4A path (for cleanup)
}
