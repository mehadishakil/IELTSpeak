//go:build azuresdk

package service

import (
	"encoding/json"
	"fmt"
	"log/slog"
	"strings"
	"sync"

	"github.com/Microsoft/cognitive-services-speech-sdk-go/audio"
	"github.com/Microsoft/cognitive-services-speech-sdk-go/common"
	"github.com/Microsoft/cognitive-services-speech-sdk-go/speech"

	myaudio "github.com/mehadishakil/ieltspeak-evaluator/internal/audio"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
)

// assessLong uses Azure Speech SDK continuous recognition with pronunciation assessment
// for audio longer than 30 seconds (e.g., Part 2 monologue ~120s, longer Part 3 responses).
// This handles long audio without splitting, using the SDK's native streaming capability.
//
// Build requirement: -tags azuresdk
// Runtime requirement: Azure Speech SDK native library (libMicrosoft.CognitiveServices.Speech.core.so)
// Install: see Dockerfile or https://learn.microsoft.com/azure/ai-services/speech-service/quickstarts/setup-platform
func (c *AzureClient) assessLong(wavFilePath string) (*model.AzureResult, error) {
	slog.Info("using Azure Speech SDK continuous mode for long audio", "path", wavFilePath)

	// Create speech config
	speechConfig, err := speech.NewSpeechConfigFromSubscription(c.speechKey, c.speechRegion)
	if err != nil {
		return nil, fmt.Errorf("failed to create speech config: %w", err)
	}
	defer speechConfig.Close()

	speechConfig.SetSpeechRecognitionLanguage("en-US")
	speechConfig.SetOutputFormat(common.Detailed)

	// Create audio config from WAV file
	audioConfig, err := audio.NewAudioConfigFromWavFileInput(wavFilePath)
	if err != nil {
		return nil, fmt.Errorf("failed to create audio config: %w", err)
	}
	defer audioConfig.Close()

	// Configure pronunciation assessment (HundredMark, Word granularity, with prosody)
	pronConfig, err := speech.NewPronunciationAssessmentConfig(
		"",             // referenceText: empty for open-ended assessment
		common.HundredMark, // grading system
		common.Word,        // granularity
		true,               // enableMiscue
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create pronunciation assessment config: %w", err)
	}
	defer pronConfig.Close()

	// Enable prosody assessment for fluency/rhythm evaluation
	pronConfig.EnableProsodyAssessment()

	// Create speech recognizer
	recognizer, err := speech.NewSpeechRecognizerFromConfig(speechConfig, audioConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create speech recognizer: %w", err)
	}
	defer recognizer.Close()

	// Apply pronunciation assessment to recognizer
	pronConfig.ApplyTo(recognizer)

	// Collect results from continuous recognition
	var mu sync.Mutex
	var allWords []model.WordDetail
	var transcriptParts []string
	var totalAccuracy, totalFluency, totalCompleteness, totalProsody, totalPron float64
	var segmentCount int
	var recognitionErr error

	done := make(chan struct{})

	// Handle recognized speech segments
	recognizer.Recognized(func(event speech.SpeechRecognitionEventArgs) {
		defer event.Close()

		result := event.Result
		if result.Reason != common.RecognizedSpeech {
			return
		}

		mu.Lock()
		defer mu.Unlock()

		transcriptParts = append(transcriptParts, result.Text)

		// Extract detailed JSON result with pronunciation scores
		jsonResultStr := result.Properties.GetPropertyByName("SpeechServiceResponse_JsonResult")
		if jsonResultStr == "" {
			slog.Debug("no JSON result for segment", "text", result.Text)
			segmentCount++
			return
		}

		var jsonResult struct {
			NBest []struct {
				Display                 string `json:"Display"`
				PronunciationAssessment struct {
					AccuracyScore     float64 `json:"AccuracyScore"`
					FluencyScore      float64 `json:"FluencyScore"`
					CompletenessScore float64 `json:"CompletenessScore"`
					ProsodyScore      float64 `json:"ProsodyScore"`
					PronScore         float64 `json:"PronScore"`
				} `json:"PronunciationAssessment"`
				Words []struct {
					Word                    string `json:"Word"`
					PronunciationAssessment struct {
						AccuracyScore float64 `json:"AccuracyScore"`
						ErrorType     string  `json:"ErrorType"`
					} `json:"PronunciationAssessment"`
				} `json:"Words"`
			} `json:"NBest"`
		}

		if err := json.Unmarshal([]byte(jsonResultStr), &jsonResult); err != nil {
			slog.Warn("failed to parse SDK JSON result", "error", err)
			segmentCount++
			return
		}

		if len(jsonResult.NBest) > 0 {
			best := jsonResult.NBest[0]
			pa := best.PronunciationAssessment

			totalAccuracy += pa.AccuracyScore
			totalFluency += pa.FluencyScore
			totalCompleteness += pa.CompletenessScore
			totalProsody += pa.ProsodyScore
			totalPron += pa.PronScore

			for _, w := range best.Words {
				allWords = append(allWords, model.WordDetail{
					Word:          w.Word,
					AccuracyScore: w.PronunciationAssessment.AccuracyScore,
					ErrorType:     w.PronunciationAssessment.ErrorType,
				})
			}
		}

		segmentCount++
		slog.Debug("recognized segment via SDK", "text", result.Text, "segment", segmentCount)
	})

	// Handle cancellation (errors or end of stream)
	recognizer.Canceled(func(event speech.SpeechRecognitionCanceledEventArgs) {
		defer event.Close()
		if event.Reason == common.Error {
			mu.Lock()
			recognitionErr = fmt.Errorf("SDK recognition canceled: %s (code: %d)", event.ErrorDetails, event.ErrorCode)
			mu.Unlock()
			slog.Error("SDK recognition error", "details", event.ErrorDetails, "code", event.ErrorCode)
		}
		select {
		case <-done:
		default:
			close(done)
		}
	})

	// Handle session stopped (normal completion)
	recognizer.SessionStopped(func(event speech.SessionEventArgs) {
		defer event.Close()
		slog.Info("SDK recognition session stopped")
		select {
		case <-done:
		default:
			close(done)
		}
	})

	// Start continuous recognition
	slog.Info("starting SDK continuous recognition")
	errChan := recognizer.StartContinuousRecognitionAsync()
	if err := <-errChan; err != nil {
		return nil, fmt.Errorf("failed to start continuous recognition: %w", err)
	}

	// Wait for recognition to complete (session stopped or canceled)
	<-done

	// Stop continuous recognition
	errChan = recognizer.StopContinuousRecognitionAsync()
	<-errChan

	mu.Lock()
	defer mu.Unlock()

	if recognitionErr != nil {
		return nil, recognitionErr
	}

	if segmentCount == 0 {
		return nil, fmt.Errorf("no speech segments recognized in SDK continuous mode")
	}

	n := float64(segmentCount)
	fullTranscript := strings.Join(transcriptParts, " ")

	// Get audio duration from the file
	duration, _ := myaudio.GetAudioDuration(wavFilePath)
	durationSecs := int(duration)

	slog.Info("SDK continuous recognition complete",
		"segments", segmentCount,
		"transcript_length", len(fullTranscript),
		"duration_secs", durationSecs,
	)

	return &model.AzureResult{
		Transcript:        fullTranscript,
		AccuracyScore:     totalAccuracy / n,
		FluencyScore:      totalFluency / n,
		CompletenessScore: totalCompleteness / n,
		ProsodyScore:      totalProsody / n,
		PronScore:         totalPron / n,
		DurationSeconds:   durationSecs,
		Words:             allWords,
	}, nil
}
