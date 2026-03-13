package service

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strings"

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

// batchedEvaluationSystemPrompt is used for the single batched GPT call
// that evaluates ALL responses and provides overall feedback in one shot.
const batchedEvaluationSystemPrompt = `You are an expert IELTS Speaking examiner with 20+ years of experience evaluating candidates at all band levels (0-9). You are provided with ALL of a candidate's responses from a single IELTS Speaking test.

Your task:
1. Evaluate EACH response INDIVIDUALLY for content quality (grammar, vocabulary, coherence, relevance)
2. Provide OVERALL holistic test feedback

For EACH response, score on the IELTS 0-9 band scale (use 0.5 increments: 0.0, 0.5, 1.0, ..., 8.5, 9.0):

SCORING CRITERIA:
- **Fluency and Coherence** (fluency_coherence_score): Speaking rhythm, hesitation patterns, logical structure, discourse markers, connectors, ability to speak at length
- **Lexical Resource** (lexical_resource_score): Vocabulary range & precision, collocations, idiomatic language, paraphrasing ability, word choice appropriateness
- **Grammatical Range and Accuracy** (grammatical_range_score): Sentence variety, tense accuracy, complex grammar, error frequency & impact on communication
- **Topic Relevance** (topic_relevance_score): How directly and fully the response addresses the question

BAND DESCRIPTORS REFERENCE:
- Band 9: Expert. Fully operational command. Natural, effortless speech.
- Band 8: Very Good. Fully operational with occasional inaccuracies. Handles complex language well.
- Band 7: Good. Effective command with occasional inaccuracies. Uses some complex language.
- Band 6: Competent. Generally effective, with notable lapses. Limited flexibility.
- Band 5: Modest. Partial command, many errors. Simple language only.
- Band 4: Limited. Basic competence limited to familiar situations.
- Band 3-below: Very limited to non-user.

Also identify specific MISTAKES in each transcript:
- Grammar: wrong tense, subject-verb agreement, articles, prepositions, etc.
- Vocabulary: wrong word choice, unnatural collocations, incorrect word forms
- Mark each with original text, correction, type, and category.

Provide brief constructive feedback per response AND overall test insights.

IMPORTANT: Return ONLY valid JSON matching the exact format specified. question_index is 0-based.`

const batchedUserPromptTemplate = `Here are the candidate's IELTS Speaking test responses:

%s

Respond with JSON in this exact format:
{
  "responses": [
    {
      "question_index": 0,
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
      "feedback": "Your response addressed the question well but lacked complex structures."
    }
  ],
  "overall": {
    "overall_feedback": "A 2-3 sentence assessment of the candidate's overall speaking performance across all parts.",
    "strengths": ["Strength 1", "Strength 2"],
    "improvements": ["Area to improve 1", "Area to improve 2"],
    "tips": ["Actionable tip 1", "Actionable tip 2"]
  }
}`

// perQuestionSystemPrompt is used as fallback for individual response evaluation.
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

// EvaluateBatched sends ALL response transcripts to GPT in a single call.
// Returns per-response scores + overall feedback. This is the cost-optimized path
// (~$0.02 for one GPT call instead of N calls).
func (c *OpenAIClient) EvaluateBatched(ctx context.Context, responses []model.AzureProcessedResponse) (*model.GPTBatchedResult, error) {
	// Build the response data for the prompt
	var parts []string
	for i, r := range responses {
		partLabel := fmt.Sprintf("Part %d", r.Response.PartNumber)
		parts = append(parts, fmt.Sprintf(
			"--- Response %d (%s, Q%d) ---\nQuestion: %s\nTranscript: %s\nDuration: %d seconds",
			i, partLabel, r.Response.QuestionOrder,
			r.Response.QuestionText,
			r.AzureResult.Transcript,
			r.AzureResult.DurationSeconds,
		))
	}

	userMsg := fmt.Sprintf(batchedUserPromptTemplate, strings.Join(parts, "\n\n"))

	resp, err := c.client.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
		Model: c.model,
		Messages: []openai.ChatCompletionMessage{
			{Role: openai.ChatMessageRoleSystem, Content: batchedEvaluationSystemPrompt},
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

	var result model.GPTBatchedResult
	if err := json.Unmarshal([]byte(resp.Choices[0].Message.Content), &result); err != nil {
		slog.Warn("failed to parse batched GPT response", "content", resp.Choices[0].Message.Content[:min(500, len(resp.Choices[0].Message.Content))])
		return nil, fmt.Errorf("failed to parse GPT batched response: %w", err)
	}

	slog.Info("batched GPT evaluation completed",
		"response_count", len(result.Responses),
		"usage_prompt_tokens", resp.Usage.PromptTokens,
		"usage_completion_tokens", resp.Usage.CompletionTokens,
	)

	return &result, nil
}

// EvaluateQuestion sends a single transcript + question to GPT for content scoring.
// Used as fallback when batched evaluation fails.
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
		slog.Warn("failed to parse GPT response", "content", resp.Choices[0].Message.Content)
		return nil, fmt.Errorf("failed to parse GPT response: %w", err)
	}

	return &result, nil
}

// GenerateOverallFeedback generates holistic test feedback from all Q&A pairs.
// Used as fallback when batched evaluation doesn't include overall feedback.
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
