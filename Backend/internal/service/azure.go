package service

import (
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"math"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/mehadishakil/ieltspeak-evaluator/internal/audio"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
)

// ShortAudioThreshold is the max duration (seconds) for REST API pronunciation assessment.
// Audio longer than this uses Azure Speech SDK continuous mode (build tag: azuresdk)
// or chunked REST API (default fallback).
const ShortAudioThreshold = 30.0

// AzureClient wraps Azure Speech Services for pronunciation assessment.
type AzureClient struct {
	speechKey    string
	speechRegion string
	httpClient   *http.Client
}

func NewAzureClient(speechKey, speechRegion string) *AzureClient {
	return &AzureClient{
		speechKey:    speechKey,
		speechRegion: speechRegion,
		httpClient:   &http.Client{Timeout: 60 * time.Second},
	}
}

// azurePronAssessmentConfig is the JSON config for the Pronunciation-Assessment header.
type azurePronAssessmentConfig struct {
	ReferenceText           string `json:"ReferenceText"`
	GradingSystem           string `json:"GradingSystem"`
	Granularity             string `json:"Granularity"`
	Dimension               string `json:"Dimension"`
	EnableMiscue            bool   `json:"EnableMiscue"`
	EnableProsodyAssessment bool   `json:"EnableProsodyAssessment"`
}

type azureResponse struct {
	RecognitionStatus string       `json:"RecognitionStatus"`
	Duration          int64        `json:"Duration"`
	NBest             []azureNBest `json:"NBest"`
}

type azureNBest struct {
	Display                 string                       `json:"Display"`
	PronunciationAssessment azurePronunciationAssessment `json:"PronunciationAssessment"`
	Words                   []azureWord                  `json:"Words"`
}

type azurePronunciationAssessment struct {
	AccuracyScore     float64 `json:"AccuracyScore"`
	FluencyScore      float64 `json:"FluencyScore"`
	CompletenessScore float64 `json:"CompletenessScore"`
	ProsodyScore      float64 `json:"ProsodyScore"`
	PronScore         float64 `json:"PronScore"`
}

type azureWord struct {
	Word                    string                  `json:"Word"`
	PronunciationAssessment azureWordPronAssessment `json:"PronunciationAssessment"`
}

type azureWordPronAssessment struct {
	AccuracyScore float64 `json:"AccuracyScore"`
	ErrorType     string  `json:"ErrorType"`
}

// Assess is the main entry point for Azure pronunciation assessment.
// Routes to REST API (<=30s) or SDK continuous mode / chunked processing (>30s).
//
// Build with -tags azuresdk to use Azure Speech SDK continuous mode for >30s audio.
// Default build uses chunked REST API as fallback.
func (c *AzureClient) Assess(wavFilePath string) (*model.AzureResult, error) {
	duration, err := audio.GetAudioDuration(wavFilePath)
	if err != nil {
		slog.Warn("could not determine audio duration, using short assessment", "error", err)
		return c.assessShort(wavFilePath)
	}

	slog.Info("audio duration detected", "duration_secs", duration, "threshold", ShortAudioThreshold)

	if duration <= ShortAudioThreshold {
		return c.assessShort(wavFilePath)
	}

	// assessLong is defined in azure_sdk.go (build tag: azuresdk)
	// or azure_chunked.go (default: !azuresdk)
	return c.assessLong(wavFilePath)
}

// assessShort sends a single WAV file to Azure REST API for pronunciation assessment.
// Optimal for audio <=30 seconds (~$0.000183/second).
func (c *AzureClient) assessShort(wavFilePath string) (*model.AzureResult, error) {
	var lastErr error

	for attempt := 0; attempt < 3; attempt++ {
		if attempt > 0 {
			delay := time.Duration(math.Pow(2, float64(attempt))) * time.Second
			slog.Info("retrying Azure assessment", "attempt", attempt+1, "delay", delay)
			time.Sleep(delay)
		}

		result, err := c.doAssess(wavFilePath)
		if err == nil {
			return result, nil
		}
		lastErr = err
		slog.Warn("Azure assessment attempt failed", "attempt", attempt+1, "error", err)
	}

	return nil, fmt.Errorf("Azure assessment failed after 3 attempts: %w", lastErr)
}

func (c *AzureClient) doAssess(wavFilePath string) (*model.AzureResult, error) {
	audioData, err := os.ReadFile(wavFilePath)
	if err != nil {
		return nil, fmt.Errorf("failed to read WAV file: %w", err)
	}

	url := fmt.Sprintf(
		"https://%s.stt.speech.microsoft.com/speech/recognition/conversation/cognitiveservices/v1?language=en-US&format=detailed&profanity=masked",
		c.speechRegion,
	)

	req, err := http.NewRequest("POST", url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	pronConfig := azurePronAssessmentConfig{
		ReferenceText:           "",
		GradingSystem:           "HundredMark",
		Granularity:             "Word",
		Dimension:               "Comprehensive",
		EnableMiscue:            true,
		EnableProsodyAssessment: true,
	}
	pronConfigJSON, _ := json.Marshal(pronConfig)

	req.Header.Set("Ocp-Apim-Subscription-Key", c.speechKey)
	req.Header.Set("Content-Type", "audio/wav; codecs=audio/pcm; samplerate=16000")
	req.Header.Set("Pronunciation-Assessment", string(pronConfigJSON))
	req.Header.Set("Accept", "application/json")

	req.Body = io.NopCloser(bytesReader(audioData))
	req.ContentLength = int64(len(audioData))

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("HTTP request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == 429 {
		retryAfter := resp.Header.Get("Retry-After")
		if secs, err := strconv.Atoi(retryAfter); err == nil {
			time.Sleep(time.Duration(secs) * time.Second)
		}
		return nil, fmt.Errorf("rate limited (429)")
	}

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("Azure API error (status %d): %s", resp.StatusCode, string(body))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	var azResp azureResponse
	if err := json.Unmarshal(body, &azResp); err != nil {
		return nil, fmt.Errorf("failed to parse Azure response: %w", err)
	}

	if azResp.RecognitionStatus != "Success" || len(azResp.NBest) == 0 {
		return nil, fmt.Errorf("Azure recognition failed: status=%s", azResp.RecognitionStatus)
	}

	best := azResp.NBest[0]
	durationSecs := int(azResp.Duration / 10000000) // Duration is in 100ns ticks

	var words []model.WordDetail
	for _, w := range best.Words {
		words = append(words, model.WordDetail{
			Word:          w.Word,
			AccuracyScore: w.PronunciationAssessment.AccuracyScore,
			ErrorType:     w.PronunciationAssessment.ErrorType,
		})
	}

	return &model.AzureResult{
		Transcript:        best.Display,
		AccuracyScore:     best.PronunciationAssessment.AccuracyScore,
		FluencyScore:      best.PronunciationAssessment.FluencyScore,
		CompletenessScore: best.PronunciationAssessment.CompletenessScore,
		ProsodyScore:      best.PronunciationAssessment.ProsodyScore,
		PronScore:         best.PronunciationAssessment.PronScore,
		DurationSeconds:   durationSecs,
		Words:             words,
		RawResponse:       body,
	}, nil
}

// bytesReaderWrapper wraps a byte slice into an io.Reader.
type bytesReaderWrapper struct {
	data []byte
	pos  int
}

func bytesReader(data []byte) *bytesReaderWrapper {
	return &bytesReaderWrapper{data: data}
}

func (r *bytesReaderWrapper) Read(p []byte) (n int, err error) {
	if r.pos >= len(r.data) {
		return 0, io.EOF
	}
	n = copy(p, r.data[r.pos:])
	r.pos += n
	return n, nil
}
