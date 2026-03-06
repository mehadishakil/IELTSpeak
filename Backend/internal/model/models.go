package model

import (
	"encoding/json"
	"time"
)

// EvaluateRequest is the payload from the edge function.
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

// ResponseWithQuestion is a joined row from responses + questions.
type ResponseWithQuestion struct {
	ResponseID     string
	AudioFilePath  string
	ProcessingOrder int
	QuestionText   string
	PartNumber     int
	QuestionOrder  int
}

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

// GPTQuestionResult is the structured JSON output from GPT-4o mini per question.
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

// ResponseScores holds the final combined scores for a single response.
type ResponseScores struct {
	ResponseID        string
	Transcript        string
	FluencyScore      float64
	PronunciationScore float64
	GrammarScore      float64
	VocabularyScore   float64
	TopicRelevance    float64
	DurationSeconds   int
	Feedback          string
	Mistakes          []Mistake
	AzureResponse     json.RawMessage // Combined Azure + GPT raw data
}

// SessionScores holds the aggregated scores for the entire test session.
type SessionScores struct {
	OverallBandScore float64
	FluencyScore     float64
	PronunciationScore float64
	GrammarScore     float64
	VocabularyScore  float64
	TopicRelevance   float64
	OverallFeedback  *GPTOverallResult
}

// HealthResponse is returned by GET /health.
type HealthResponse struct {
	Status    string    `json:"status"`
	Redis     string    `json:"redis"`
	DB        string    `json:"db"`
	Timestamp time.Time `json:"timestamp"`
}
