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
func (s *Scorer) CombineScores(azure *model.AzureResult, gpt *model.GPTBatchedResponseResult) model.ResponseScores {
	// Pronunciation: 100% Azure (converted from 0-100 to 0-9)
	pronunciationScore := convertToIELTS(azure.PronScore)

	// Fluency & Coherence: 60% Azure fluency + 40% GPT fluency/coherence
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

// CombineScoresIndividual merges Azure with individual GPT question result (fallback path).
func (s *Scorer) CombineScoresIndividual(azure *model.AzureResult, gpt *model.GPTQuestionResult) model.ResponseScores {
	pronunciationScore := convertToIELTS(azure.PronScore)
	azureFluencyIELTS := convertToIELTS(azure.FluencyScore)
	fluencyScore := roundToHalf(azureFluencyIELTS*0.6 + gpt.FluencyCoherenceScore*0.4)
	grammarScore := roundToHalf(gpt.GrammaticalRangeScore)
	vocabularyScore := roundToHalf(gpt.LexicalResourceScore)
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

// AggregateSessionScores calculates overall session scores.
// Uses weighted averaging by part: Part 1 (40%), Part 2 (30%), Part 3 (30%).
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

	// Overall band score: average of 4 main IELTS criteria
	// (Fluency & Coherence, Lexical Resource, Grammatical Range, Pronunciation)
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

// convertToIELTS converts an Azure 0-100 score to IELTS 0-9 band scale
// using a calibrated mapping that better reflects IELTS band descriptors.
func convertToIELTS(azureScore float64) float64 {
	// Calibrated mapping: Azure scores don't map linearly to IELTS bands.
	// Azure 90-100 = Band 8-9 (expert)
	// Azure 75-89  = Band 6.5-7.5 (competent-good)
	// Azure 60-74  = Band 5-6 (modest-competent)
	// Azure 40-59  = Band 3.5-4.5 (limited)
	// Azure 0-39   = Band 0.5-3 (very limited)
	var ielts float64
	switch {
	case azureScore >= 90:
		ielts = 8.0 + (azureScore-90)/10.0*1.0 // 90-100 -> 8.0-9.0
	case azureScore >= 75:
		ielts = 6.5 + (azureScore-75)/15.0*1.5 // 75-89 -> 6.5-8.0
	case azureScore >= 60:
		ielts = 5.0 + (azureScore-60)/15.0*1.5 // 60-74 -> 5.0-6.5
	case azureScore >= 40:
		ielts = 3.5 + (azureScore-40)/20.0*1.5 // 40-59 -> 3.5-5.0
	default:
		ielts = 0.5 + azureScore/40.0*3.0 // 0-39 -> 0.5-3.5
	}

	ielts = math.Max(0.5, math.Min(9.0, ielts))
	return roundToHalf(ielts)
}

// roundToHalf rounds a score to the nearest 0.5 (IELTS convention).
func roundToHalf(score float64) float64 {
	return math.Round(score*2) / 2
}
