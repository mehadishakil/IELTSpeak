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
	store  *storage.SupabaseStore
	r2     *storage.R2Client // nil if R2 not configured
	azure  *AzureClient
	openai *OpenAIClient
	scorer *Scorer
}

func NewEvaluator(store *storage.SupabaseStore, r2 *storage.R2Client, azure *AzureClient, openai *OpenAIClient, scorer *Scorer) *Evaluator {
	return &Evaluator{
		store:  store,
		r2:     r2,
		azure:  azure,
		openai: openai,
		scorer: scorer,
	}
}

// EvaluateSession runs the full evaluation pipeline for a test session.
//
// Pipeline:
//
//	Phase 1: Setup — fetch responses, update status
//	Phase 2: Azure processing — per-response pronunciation assessment (hybrid short/long)
//	Phase 3: Batched GPT evaluation — single call for all transcripts (cost-optimized)
//	Phase 4: Score combination + DB updates
//	Phase 5: Session aggregation + overall feedback
func (e *Evaluator) EvaluateSession(ctx context.Context, sessionID, userID string) error {
	startTime := time.Now()

	// Idempotency check
	status, err := e.store.CheckSessionStatus(sessionID)
	if err != nil {
		return fmt.Errorf("failed to check session status: %w", err)
	}
	if status == "evaluated" {
		slog.Info("session already evaluated, skipping", "session_id", sessionID)
		return nil
	}

	// ==================== Phase 1: Setup ====================
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

	// ==================== Phase 2: Azure Processing ====================
	slog.Info("phase 2: Azure pronunciation assessment", "session_id", sessionID)

	var azureProcessed []model.AzureProcessedResponse
	for i, resp := range responses {
		slog.Info("Azure processing response",
			"session_id", sessionID,
			"response_id", resp.ResponseID,
			"index", i+1,
			"total", len(responses),
		)

		azResult, err := e.processAzure(ctx, resp)
		if err != nil {
			slog.Error("Azure processing failed",
				"response_id", resp.ResponseID,
				"error", err,
			)
			e.store.MarkResponseFailed(resp.ResponseID, fmt.Sprintf("Azure failed: %s", err.Error()))
			continue
		}

		azureProcessed = append(azureProcessed, model.AzureProcessedResponse{
			ResponseIndex: i,
			Response:      resp,
			AzureResult:   azResult,
		})

		// Rate limit between responses
		if i < len(responses)-1 {
			time.Sleep(500 * time.Millisecond)
		}
	}

	if len(azureProcessed) == 0 {
		e.markSessionFailed(sessionID, "all Azure assessments failed")
		return fmt.Errorf("all Azure assessments failed for session %s", sessionID)
	}

	slog.Info("Azure processing complete",
		"session_id", sessionID,
		"successful", len(azureProcessed),
		"total", len(responses),
	)

	// ==================== Phase 3: Batched GPT Evaluation ====================
	slog.Info("phase 3: batched GPT evaluation", "session_id", sessionID)

	var evaluatedScores []model.ResponseScores

	batchedResult, err := e.openai.EvaluateBatched(ctx, azureProcessed)
	if err != nil {
		slog.Warn("batched GPT evaluation failed, falling back to individual calls",
			"session_id", sessionID,
			"error", err,
		)
		evaluatedScores = e.fallbackIndividualGPT(ctx, azureProcessed)
	} else {
		evaluatedScores = e.combineWithBatchedGPT(azureProcessed, batchedResult)
	}

	// ==================== Phase 4: DB Updates ====================
	slog.Info("phase 4: storing scores", "session_id", sessionID, "scored_count", len(evaluatedScores))

	successCount := 0
	for _, scores := range evaluatedScores {
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
			slog.Error("failed to update response scores",
				"response_id", scores.ResponseID,
				"error", err,
			)
			continue
		}
		successCount++
	}

	if successCount == 0 {
		e.markSessionFailed(sessionID, "failed to store any scores")
		return fmt.Errorf("failed to store any scores for session %s", sessionID)
	}

	// ==================== Phase 5: Aggregation ====================
	slog.Info("phase 5: aggregation", "session_id", sessionID, "successful_responses", successCount)

	sessionScores := e.scorer.AggregateSessionScores(evaluatedScores)

	// Overall feedback: use batched result if available, otherwise generate separately
	if batchedResult != nil && batchedResult.Overall.OverallFeedback != "" {
		sessionScores.OverallFeedback = &batchedResult.Overall
	} else {
		// Build Q&A data for separate overall feedback call
		var qaDataParts []string
		for _, scores := range evaluatedScores {
			qaDataParts = append(qaDataParts, fmt.Sprintf(
				"Transcript: %s\nScores - Fluency: %.1f, Pronunciation: %.1f, Grammar: %.1f, Vocabulary: %.1f",
				scores.Transcript, scores.FluencyScore, scores.PronunciationScore,
				scores.GrammarScore, scores.VocabularyScore,
			))
		}
		qaData := strings.Join(qaDataParts, "\n\n")
		overallFeedback, err := e.openai.GenerateOverallFeedback(ctx, qaData)
		if err != nil {
			slog.Warn("failed to generate overall feedback", "error", err)
		} else {
			sessionScores.OverallFeedback = overallFeedback
		}
	}

	if err := e.store.UpdateSessionScores(sessionID, &sessionScores); err != nil {
		return fmt.Errorf("failed to update session scores: %w", err)
	}

	e.store.UpdateSessionProcessingQueue(sessionID, "completed")

	// Increment user's test count for quota tracking
	if userID != "" {
		if err := e.store.IncrementUserTestCount(userID); err != nil {
			slog.Warn("failed to increment user test count", "user_id", userID, "error", err)
		}
	}

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

// processAzure handles downloading audio and running Azure assessment for a single response.
func (e *Evaluator) processAzure(ctx context.Context, resp model.ResponseWithQuestion) (*model.AzureResult, error) {
	// Download audio: prefer R2, fall back to Supabase Storage
	audioData, err := e.downloadAudio(ctx, resp)
	if err != nil {
		return nil, fmt.Errorf("download failed: %w", err)
	}

	// Save to temp file
	m4aPath, err := audio.SaveTempFile(audioData, fmt.Sprintf("eval_%s", resp.ResponseID), ".m4a")
	if err != nil {
		return nil, fmt.Errorf("save temp failed: %w", err)
	}
	defer audio.CleanupFile(m4aPath)

	// Convert to WAV (16kHz, mono, PCM s16le)
	wavPath := strings.TrimSuffix(m4aPath, ".m4a") + ".wav"
	defer audio.CleanupFile(wavPath)

	if err := audio.ConvertM4AToWAV(m4aPath, wavPath); err != nil {
		return nil, fmt.Errorf("conversion failed: %w", err)
	}

	// Azure assessment (auto-routes to short/long based on duration)
	azureResult, err := e.azure.Assess(wavPath)
	if err != nil {
		return nil, fmt.Errorf("Azure assessment failed: %w", err)
	}

	return azureResult, nil
}

// downloadAudio downloads audio from R2 (preferred) or Supabase Storage (fallback).
func (e *Evaluator) downloadAudio(ctx context.Context, resp model.ResponseWithQuestion) ([]byte, error) {
	// Prefer R2 if key is set and client available
	if resp.R2Key != "" && e.r2 != nil {
		slog.Info("downloading from R2", "r2_key", resp.R2Key)
		return e.r2.DownloadFile(ctx, resp.R2Key)
	}

	// Fall back to Supabase Storage
	if resp.AudioFilePath != "" {
		slog.Info("downloading from Supabase Storage (legacy)", "path", resp.AudioFilePath)
		return e.store.DownloadAudio(resp.AudioFilePath)
	}

	return nil, fmt.Errorf("no audio source available for response %s (no r2_key or audio_file_path)", resp.ResponseID)
}

// combineWithBatchedGPT combines Azure results with batched GPT scores.
func (e *Evaluator) combineWithBatchedGPT(azureProcessed []model.AzureProcessedResponse, gptResult *model.GPTBatchedResult) []model.ResponseScores {
	var scores []model.ResponseScores

	// Build a map of GPT results by question_index for matching
	gptMap := make(map[int]*model.GPTBatchedResponseResult)
	for i := range gptResult.Responses {
		gptMap[gptResult.Responses[i].QuestionIndex] = &gptResult.Responses[i]
	}

	for i, ap := range azureProcessed {
		gptResp, ok := gptMap[i]
		if !ok {
			// GPT didn't return result for this index, use Azure-only
			slog.Warn("no GPT result for response index, using Azure-only", "index", i)
			azureOnly := e.scorer.CombineScoresAzureOnly(ap.AzureResult)
			azureOnly.ResponseID = ap.Response.ResponseID
			scores = append(scores, azureOnly)
			continue
		}

		combined := e.scorer.CombineScores(ap.AzureResult, gptResp)
		combined.ResponseID = ap.Response.ResponseID
		scores = append(scores, combined)
	}

	return scores
}

// fallbackIndividualGPT evaluates each response individually when batched GPT fails.
func (e *Evaluator) fallbackIndividualGPT(ctx context.Context, azureProcessed []model.AzureProcessedResponse) []model.ResponseScores {
	var scores []model.ResponseScores

	for _, ap := range azureProcessed {
		gptResult, err := e.openai.EvaluateQuestion(
			ctx,
			ap.Response.QuestionText,
			ap.AzureResult.Transcript,
			ap.Response.PartNumber,
			ap.AzureResult.DurationSeconds,
		)
		if err != nil {
			slog.Warn("individual GPT evaluation failed, using Azure-only",
				"response_id", ap.Response.ResponseID,
				"error", err,
			)
			azureOnly := e.scorer.CombineScoresAzureOnly(ap.AzureResult)
			azureOnly.ResponseID = ap.Response.ResponseID
			scores = append(scores, azureOnly)
			continue
		}

		combined := e.scorer.CombineScoresIndividual(ap.AzureResult, gptResult)
		combined.ResponseID = ap.Response.ResponseID
		scores = append(scores, combined)
	}

	return scores
}

func (e *Evaluator) markSessionFailed(sessionID, errorMsg string) {
	if err := e.store.UpdateSessionStatus(sessionID, "failed"); err != nil {
		slog.Error("failed to mark session as failed", "session_id", sessionID, "error", err)
	}
	e.store.UpdateSessionProcessingQueue(sessionID, "failed")
}
