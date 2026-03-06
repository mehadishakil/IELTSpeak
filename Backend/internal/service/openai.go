package service

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"

	openai "github.com/sashabaranov/go-openai"
	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
)

type OpenAIClient struct {
	client *openai.Client
	model  string
}

func NewOpenAIClient(apiKey, modelName string) *OpenAIClient {
	return &OpenAIClient{
		client: openai.NewClient(apiKey),
		model:  modelName,
	}
}

const perQuestionSystemPrompt = `You are an expert IELTS Speaking examiner with extensive experience evaluating candidates.
Analyze the candidate's response transcript and provide detailed scoring and feedback.

Score each criterion on the IELTS 0-9 band scale (use 0.5 increments only: 0.0, 0.5, 1.0, ..., 8.5, 9.0).

Scoring Criteria:
1. Fluency and Coherence: Speaking rhythm, hesitation patterns, logical structure, use of discourse markers and connectors, ability to speak at length without noticeable effort
2. Lexical Resource: Vocabulary range and precision, use of collocations, idiomatic language, ability to paraphrase, word choice appropriateness
3. Grammatical Range and Accuracy: Sentence structure variety, tense usage accuracy, complex grammar usage, error frequency and impact
4. Topic Relevance: How directly and fully the response addresses the question asked

Also identify specific mistakes in the transcript:
- Grammar mistakes (wrong tense, subject-verb agreement, article errors, preposition errors, etc.)
- Vocabulary mistakes (wrong word choice, unnatural collocations, incorrect word forms)
- Mark each mistake with the original text, the correction, and the mistake type.

Provide brief constructive feedback specific to this question response.

Respond ONLY with valid JSON in this exact format:
{
  "fluency_coherence_score": 6.5,
  "lexical_resource_score": 6.0,
  "grammatical_range_score": 6.0,
  "topic_relevance_score": 7.0,
  "mistakes": [
    {
      "original": "I go to school yesterday",
      "correction": "I went to school yesterday",
      "type": "grammar",
      "category": "tense",
      "start_index": 0,
      "end_index": 28
    }
  ],
  "feedback": "Your response addressed the question well but consider using more complex sentence structures."
}`

const overallFeedbackSystemPrompt = `You are an expert IELTS Speaking examiner providing overall test feedback.
Given the candidate's question-response pairs with their individual scores, provide a comprehensive assessment.

Respond ONLY with valid JSON in this exact format:
{
  "overall_feedback": "A 2-3 sentence overall assessment of the candidate's speaking performance.",
  "strengths": ["Strength 1", "Strength 2"],
  "improvements": ["Area for improvement 1", "Area for improvement 2"],
  "tips": ["Specific actionable tip 1", "Specific actionable tip 2"]
}`

// EvaluateQuestion sends a transcript + question to GPT-4o mini for content scoring.
func (c *OpenAIClient) EvaluateQuestion(ctx context.Context, questionText, transcript string, partNumber, durationSecs int) (*model.GPTQuestionResult, error) {
	userMsg := fmt.Sprintf(
		"Question: %s\nCandidate Response Transcript: %s\nResponse Duration: %d seconds\nPart: %d",
		questionText, transcript, durationSecs, partNumber,
	)

	resp, err := c.client.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
		Model: c.model,
		Messages: []openai.ChatCompletionMessage{
			{Role: openai.ChatMessageRoleSystem, Content: perQuestionSystemPrompt},
			{Role: openai.ChatMessageRoleUser, Content: userMsg},
		},
		ResponseFormat: &openai.ChatCompletionResponseFormat{
			Type: openai.ChatCompletionResponseFormatTypeJSONObject,
		},
		Temperature: 0.3,
	})
	if err != nil {
		return nil, fmt.Errorf("OpenAI API error: %w", err)
	}

	if len(resp.Choices) == 0 {
		return nil, fmt.Errorf("no response from OpenAI")
	}

	var result model.GPTQuestionResult
	if err := json.Unmarshal([]byte(resp.Choices[0].Message.Content), &result); err != nil {
		slog.Warn("failed to parse GPT response, raw content", "content", resp.Choices[0].Message.Content)
		return nil, fmt.Errorf("failed to parse GPT response: %w", err)
	}

	return &result, nil
}

// GenerateOverallFeedback generates holistic test feedback from all Q&A pairs.
func (c *OpenAIClient) GenerateOverallFeedback(ctx context.Context, qaData string) (*model.GPTOverallResult, error) {
	resp, err := c.client.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
		Model: c.model,
		Messages: []openai.ChatCompletionMessage{
			{Role: openai.ChatMessageRoleSystem, Content: overallFeedbackSystemPrompt},
			{Role: openai.ChatMessageRoleUser, Content: qaData},
		},
		ResponseFormat: &openai.ChatCompletionResponseFormat{
			Type: openai.ChatCompletionResponseFormatTypeJSONObject,
		},
		Temperature: 0.3,
	})
	if err != nil {
		return nil, fmt.Errorf("OpenAI API error: %w", err)
	}

	if len(resp.Choices) == 0 {
		return nil, fmt.Errorf("no response from OpenAI")
	}

	var result model.GPTOverallResult
	if err := json.Unmarshal([]byte(resp.Choices[0].Message.Content), &result); err != nil {
		return nil, fmt.Errorf("failed to parse GPT overall feedback: %w", err)
	}

	return &result, nil
}
