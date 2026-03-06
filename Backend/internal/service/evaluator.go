package service

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"github.com/mehadishakil/ieltspeak-evaluator/internal/audio"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/storage"
)

type Evaluator struct {
	store    *storage.SupabaseStore
	azure    *AzureClient
	openai   *OpenAIClient
	scorer   *Scorer
}

func NewEvaluator(store *storage.SupabaseStore, azure *AzureClient, openai *OpenAIClient, scorer *Scorer) *Evaluator {
	return &Evaluator{
		store:  store,
		azure:  azure,
		openai: openai,
		scorer: scorer,
	}
}

// EvaluateSession runs the full evaluation pipeline for a test session.
func (e *Evaluator) EvaluateSession(ctx context.Context, sessionID, userID string) error {
	startTime := time.Now()

	// Check idempotency
	status, err := e.store.CheckSessionStatus(sessionID)
	if err != nil {
		return fmt.Errorf("failed to check session status: %w", err)
	}
	if status == "evaluated" {
		slog.Info("session already evaluated, skipping", "session_id", sessionID)
		return nil
	}

	// Phase 1: Setup
	slog.Info("phase 1: setup", "session_id", sessionID)

	if err := e.store.UpdateSessionStatus(sessionID, "processing"); err != nil {
		return fmt.Errorf("failed to update session status: %w", err)
	}
	e.store.UpdateSessionProcessingQueue(sessionID, "processing")

	responses, err := e.store.FetchSessionResponses(sessionID)
	if err != nil {
		e.markSessionFailed(sessionID, err.Error())
		return fmt.Errorf("failed to fetch responses: %w", err)
	}

	if len(responses) == 0 {
		e.markSessionFailed(sessionID, "no responses found")
		return fmt.Errorf("no responses found for session %s", sessionID)
	}

	slog.Info("found responses", "session_id", sessionID, "count", len(responses))

	// Phase 2: Per-response evaluation
	slog.Info("phase 2: per-response evaluation", "session_id", sessionID)

	var evaluatedScores []model.ResponseScores
	var qaDataParts []string
	successCount := 0

	for i, resp := range responses {
		slog.Info("processing response",
			"session_id", sessionID,
			"response_id", resp.ResponseID,
			"index", i+1,
			"total", len(responses),
		)

		scores, err := e.evaluateResponse(ctx, resp)
		if err != nil {
			slog.Error("response evaluation failed",
				"response_id", resp.ResponseID,
				"error", err,
			)
			e.store.MarkResponseFailed(resp.ResponseID, err.Error())
			continue
		}

		scores.ResponseID = resp.ResponseID

		// Build combined azure_response JSONB
		combinedData := map[string]interface{}{
			"azure_scores": map[string]interface{}{
				"pronunciation": scores.PronunciationScore,
				"fluency":       scores.FluencyScore,
			},
			"gpt_scores": map[string]interface{}{
				"grammar":    scores.GrammarScore,
				"vocabulary": scores.VocabularyScore,
				"relevance":  scores.TopicRelevance,
			},
			"mistakes": scores.Mistakes,
			"feedback": scores.Feedback,
		}
		scores.AzureResponse, _ = json.Marshal(combinedData)

		if err := e.store.UpdateResponseScores(&scores); err != nil {
			slog.Error("failed to update response scores", "response_id", resp.ResponseID, "error", err)
			continue
		}

		evaluatedScores = append(evaluatedScores, scores)
		successCount++

		// Build Q&A summary for overall feedback
		qaDataParts = append(qaDataParts, fmt.Sprintf(
			"Part %d, Q%d:\nQuestion: %s\nResponse: %s\nScores - Fluency: %.1f, Pronunciation: %.1f, Grammar: %.1f, Vocabulary: %.1f, Relevance: %.1f",
			resp.PartNumber, resp.QuestionOrder, resp.QuestionText, scores.Transcript,
			scores.FluencyScore, scores.PronunciationScore, scores.GrammarScore, scores.VocabularyScore, scores.TopicRelevance,
		))

		// Rate limit spacing between responses
		if i < len(responses)-1 {
			time.Sleep(500 * time.Millisecond)
		}
	}

	if successCount == 0 {
		e.markSessionFailed(sessionID, "all response evaluations failed")
		return fmt.Errorf("all response evaluations failed for session %s", sessionID)
	}

	// Phase 3: Aggregation
	slog.Info("phase 3: aggregation", "session_id", sessionID, "successful_responses", successCount)

	sessionScores := e.scorer.AggregateSessionScores(evaluatedScores)

	// Generate overall feedback via GPT
	qaData := strings.Join(qaDataParts, "\n\n")
	overallFeedback, err := e.openai.GenerateOverallFeedback(ctx, qaData)
	if err != nil {
		slog.Warn("failed to generate overall feedback, proceeding without it", "error", err)
	} else {
		sessionScores.OverallFeedback = overallFeedback
	}

	if err := e.store.UpdateSessionScores(sessionID, &sessionScores); err != nil {
		return fmt.Errorf("failed to update session scores: %w", err)
	}

	e.store.UpdateSessionProcessingQueue(sessionID, "completed")

	duration := time.Since(startTime)
	slog.Info("evaluation completed",
		"session_id", sessionID,
		"overall_band", sessionScores.OverallBandScore,
		"duration_ms", duration.Milliseconds(),
		"processed", successCount,
		"total", len(responses),
	)

	return nil
}

// evaluateResponse processes a single response: download → convert → Azure → GPT → combine.
func (e *Evaluator) evaluateResponse(ctx context.Context, resp model.ResponseWithQuestion) (model.ResponseScores, error) {
	// Step 1: Download audio
	audioData, err := e.store.DownloadAudio(resp.AudioFilePath)
	if err != nil {
		return model.ResponseScores{}, fmt.Errorf("download failed: %w", err)
	}

	// Step 2: Save to temp file and convert
	m4aPath, err := audio.SaveTempFile(audioData, fmt.Sprintf("eval_%s", resp.ResponseID), ".m4a")
	if err != nil {
		return model.ResponseScores{}, fmt.Errorf("save temp failed: %w", err)
	}
	defer audio.CleanupFile(m4aPath)

	wavPath := strings.TrimSuffix(m4aPath, ".m4a") + ".wav"
	defer audio.CleanupFile(wavPath)

	if err := audio.ConvertM4AToWAV(m4aPath, wavPath); err != nil {
		return model.ResponseScores{}, fmt.Errorf("conversion failed: %w", err)
	}

	// Step 3: Azure Pronunciation Assessment
	azureResult, err := e.azure.Assess(wavPath)
	if err != nil {
		return model.ResponseScores{}, fmt.Errorf("Azure assessment failed: %w", err)
	}

	// Step 4: GPT-4o mini content analysis
	gptResult, err := e.openai.EvaluateQuestion(ctx, resp.QuestionText, azureResult.Transcript, resp.PartNumber, azureResult.DurationSeconds)
	if err != nil {
		slog.Warn("GPT evaluation failed, using Azure-only scores", "response_id", resp.ResponseID, "error", err)
		return e.scorer.CombineScoresAzureOnly(azureResult), nil
	}

	// Step 5: Combine scores
	return e.scorer.CombineScores(azureResult, gptResult), nil
}

func (e *Evaluator) markSessionFailed(sessionID, errorMsg string) {
	if err := e.store.UpdateSessionStatus(sessionID, "failed"); err != nil {
		slog.Error("failed to mark session as failed", "session_id", sessionID, "error", err)
	}
	e.store.UpdateSessionProcessingQueue(sessionID, "failed")
}
