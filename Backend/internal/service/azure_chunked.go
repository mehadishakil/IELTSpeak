//go:build !azuresdk

package service

import (
	"fmt"
	"log/slog"
	"strings"
	"time"

	"github.com/mehadishakil/ieltspeak-evaluator/internal/audio"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
)

// assessLong processes audio >30 seconds by splitting into chunks and aggregating.
// This is the default fallback when the Azure Speech SDK is not available.
//
// For Azure Speech SDK continuous mode (recommended for production), build with:
//
//	go build -tags azuresdk ./cmd/server
//
// The SDK approach handles long audio without splitting and provides better
// cross-segment fluency/prosody assessment.
func (c *AzureClient) assessLong(wavFilePath string) (*model.AzureResult, error) {
	slog.Info("using chunked REST API for long audio (build without azuresdk tag)", "path", wavFilePath)

	chunks, err := audio.SplitAudioIntoChunks(wavFilePath, ShortAudioThreshold)
	if err != nil {
		return nil, fmt.Errorf("failed to split audio into chunks: %w", err)
	}

	// Clean up chunk files when done (but not the original if it was returned as-is)
	defer func() {
		for _, chunk := range chunks {
			if chunk != wavFilePath {
				audio.CleanupFile(chunk)
			}
		}
	}()

	slog.Info("processing long audio in chunks", "chunk_count", len(chunks))

	var allWords []model.WordDetail
	var totalAccuracy, totalFluency, totalCompleteness, totalProsody, totalPron float64
	var transcriptParts []string
	var totalDuration int
	validChunks := 0

	for i, chunkPath := range chunks {
		slog.Info("assessing chunk", "index", i+1, "total", len(chunks))

		result, err := c.assessShort(chunkPath)
		if err != nil {
			slog.Warn("chunk assessment failed, skipping", "chunk_index", i, "error", err)
			continue
		}

		transcriptParts = append(transcriptParts, result.Transcript)
		totalAccuracy += result.AccuracyScore
		totalFluency += result.FluencyScore
		totalCompleteness += result.CompletenessScore
		totalProsody += result.ProsodyScore
		totalPron += result.PronScore
		totalDuration += result.DurationSeconds
		allWords = append(allWords, result.Words...)
		validChunks++

		// Rate limit between chunks to avoid Azure throttling
		if i < len(chunks)-1 {
			time.Sleep(300 * time.Millisecond)
		}
	}

	if validChunks == 0 {
		return nil, fmt.Errorf("all %d chunk assessments failed", len(chunks))
	}

	n := float64(validChunks)
	fullTranscript := strings.Join(transcriptParts, " ")

	return &model.AzureResult{
		Transcript:        fullTranscript,
		AccuracyScore:     totalAccuracy / n,
		FluencyScore:      totalFluency / n,
		CompletenessScore: totalCompleteness / n,
		ProsodyScore:      totalProsody / n,
		PronScore:         totalPron / n,
		DurationSeconds:   totalDuration,
		Words:             allWords,
	}, nil
}
