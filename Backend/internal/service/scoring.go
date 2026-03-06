package service

import (
	"math"

	"github.com/mehadishakil/ieltspeak-evaluator/internal/model"
)

type Scorer struct{}

func NewScorer() *Scorer {
	return &Scorer{}
}

// CombineScores merges Azure pronunciation scores with GPT content scores
// into final IELTS band scores for a single response.
func (s *Scorer) CombineScores(azure *model.AzureResult, gpt *model.GPTQuestionResult) model.ResponseScores {
	// Pronunciation: 100% Azure
	pronunciationScore := convertToIELTS(azure.PronScore)

	// Fluency & Coherence: 60% Azure + 40% GPT
	azureFluencyIELTS := convertToIELTS(azure.FluencyScore)
	fluencyScore := roundToHalf(azureFluencyIELTS*0.6 + gpt.FluencyCoherenceScore*0.4)

	// Grammar: 100% GPT
	grammarScore := roundToHalf(gpt.GrammaticalRangeScore)

	// Vocabulary: 100% GPT
	vocabularyScore := roundToHalf(gpt.LexicalResourceScore)

	// Topic Relevance: 100% GPT
	topicRelevance := roundToHalf(gpt.TopicRelevanceScore)

	return model.ResponseScores{
		Transcript:         azure.Transcript,
		FluencyScore:       fluencyScore,
		PronunciationScore: pronunciationScore,
		GrammarScore:       grammarScore,
		VocabularyScore:    vocabularyScore,
		TopicRelevance:     topicRelevance,
		DurationSeconds:    azure.DurationSeconds,
		Feedback:           gpt.Feedback,
		Mistakes:           gpt.Mistakes,
	}
}

// CombineScoresAzureOnly derives all scores from Azure when GPT fails (fallback).
func (s *Scorer) CombineScoresAzureOnly(azure *model.AzureResult) model.ResponseScores {
	pronScore := convertToIELTS(azure.PronScore)
	fluencyScore := convertToIELTS(azure.FluencyScore)
	// Approximate grammar/vocabulary from completeness (rough fallback)
	completenessIELTS := convertToIELTS(azure.CompletenessScore)

	return model.ResponseScores{
		Transcript:         azure.Transcript,
		FluencyScore:       fluencyScore,
		PronunciationScore: pronScore,
		GrammarScore:       completenessIELTS,
		VocabularyScore:    completenessIELTS,
		TopicRelevance:     completenessIELTS,
		DurationSeconds:    azure.DurationSeconds,
	}
}

// AggregateSessionScores calculates overall session scores by averaging per-response scores.
func (s *Scorer) AggregateSessionScores(responses []model.ResponseScores) model.SessionScores {
	if len(responses) == 0 {
		return model.SessionScores{}
	}

	var totalFluency, totalPron, totalGrammar, totalVocab, totalRelevance float64
	for _, r := range responses {
		totalFluency += r.FluencyScore
		totalPron += r.PronunciationScore
		totalGrammar += r.GrammarScore
		totalVocab += r.VocabularyScore
		totalRelevance += r.TopicRelevance
	}

	n := float64(len(responses))
	fluency := roundToHalf(totalFluency / n)
	pron := roundToHalf(totalPron / n)
	grammar := roundToHalf(totalGrammar / n)
	vocab := roundToHalf(totalVocab / n)
	relevance := roundToHalf(totalRelevance / n)

	// Overall band score: average of 4 main criteria (IELTS standard)
	overall := roundToHalf((fluency + pron + grammar + vocab) / 4.0)

	return model.SessionScores{
		OverallBandScore:   overall,
		FluencyScore:       fluency,
		PronunciationScore: pron,
		GrammarScore:       grammar,
		VocabularyScore:    vocab,
		TopicRelevance:     relevance,
	}
}

// convertToIELTS converts an Azure 0-100 score to IELTS 0-9 band scale.
func convertToIELTS(azureScore float64) float64 {
	ielts := azureScore / 100.0 * 9.0
	ielts = math.Max(0.5, math.Min(9.0, ielts))
	return roundToHalf(ielts)
}

// roundToHalf rounds a score to the nearest 0.5 (IELTS convention).
func roundToHalf(score float64) float64 {
	return math.Round(score*2) / 2
}
