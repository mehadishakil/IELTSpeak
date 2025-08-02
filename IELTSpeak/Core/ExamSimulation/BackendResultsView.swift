//
//  BackendResultsView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 2/8/25.
//


import SwiftUI

// MARK: - Backend Results View
struct BackendResultsView: View {
    let testResults: TestResults
    let localConversations: [Conversation]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ResultsHeaderSection(results: testResults)
                    
                    ScoreBreakdownSection(results: testResults)
                    
                    TranscriptSection(
                        responses: testResults.responses,
                        conversations: localConversations
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Test Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Results Header Section
struct ResultsHeaderSection: View {
    let results: TestResults
    
    private var bandScoreColor: Color {
        switch results.overallBandScore {
        case 8.0...9.0: return .green
        case 6.5..<8.0: return .blue
        case 5.0..<6.5: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall Band Score
            VStack(spacing: 8) {
                Text("Overall Band Score")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(String(format: "%.1f", results.overallBandScore))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(bandScoreColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(bandScoreColor.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(bandScoreColor.opacity(0.3), lineWidth: 2)
                    )
            )
            
            // Completion Info
            Text("Test completed on \(results.completedAt, formatter: dateFormatter)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: - Score Row Component
struct ScoreRow: View {
    let title: String
    let score: Double
    let icon: String
    
    private var scoreColor: Color {
        switch score {
        case 8.0...9.0: return .green
        case 6.5..<8.0: return .blue
        case 5.0..<6.5: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(scoreColor)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(String(format: "%.1f", score))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(scoreColor)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Transcript Section
struct TranscriptSection: View {
    let responses: [ResponseResult]
    let conversations: [Conversation]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Responses")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(Array(responses.enumerated()), id: \.offset) { index, response in
                    TranscriptCard(
                        response: response,
                        conversation: getConversation(for: index),
                        questionNumber: index + 1
                    )
                }
            }
        }
    }
    
    private func getConversation(for index: Int) -> Conversation? {
        guard index < conversations.count else { return nil }
        return conversations[index]
    }
}

// MARK: - Transcript Card
struct TranscriptCard: View {
    let response: ResponseResult
    let conversation: Conversation?
    let questionNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Question \(questionNumber)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let conv = conversation {
                    Text("Part \(conv.part)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // Question Text (if available)
            if let conversation = conversation {
                Text(conversation.question)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // AI Transcript
            VStack(alignment: .leading, spacing: 8) {
                Text("AI Transcript:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(response.transcript.isEmpty ? "No transcript available" : response.transcript)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding()
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            
            // Scores
            HStack(spacing: 16) {
                ScorePill(
                    title: "Fluency",
                    score: response.fluencyScore,
                    color: .blue
                )
                
                ScorePill(
                    title: "Pronunciation", 
                    score: response.pronunciationScore,
                    color: .green
                )
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Score Pill Component
struct ScorePill: View {
    let title: String
    let score: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(String(format: "%.1f", score))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}


struct ScoreBreakdownSection: View {
    let results: TestResults
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Breakdown")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ScoreRow(
                    title: "Fluency & Coherence",
                    score: results.fluencyScore,
                    icon: "waveform"
                )
                
                ScoreRow(
                    title: "Pronunciation",
                    score: results.pronunciationScore,
                    icon: "speaker.wave.2"
                )
                
                ScoreRow(
                    title: "Lexical Resource",
                    score: results.vocabularyScore,
                    icon: "book"
                )
                
                ScoreRow(
                    title: "Grammatical Range",
                    score: results.grammarScore,
                    icon: "textformat.abc"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Score
