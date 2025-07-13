//
//  FeedbackScreen.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import SwiftUI

// MARK: - Feedback Screen
struct FeedbackScreen: View {
    let testResult: TestResult
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Tab Selection
                tabSelector
                
                // Content
                TabView(selection: $selectedTab) {
                    // AI Feedback Tab
                    aiFeedbackTab
                        .tag(0)
                    
                    // Conversation Analysis Tab
                    conversationAnalysisTab
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text("Test Feedback")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 44)
            
            // Score Display
            VStack(spacing: 8) {
                Text("Overall Band Score")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(String(format: "%.1f", testResult.bandScore))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(testResult.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<2) { index in
                Button(action: { selectedTab = index }) {
                    VStack(spacing: 8) {
                        Text(index == 0 ? "AI Feedback" : "Conversation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == index ? .blue : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
    }
    
    private var aiFeedbackTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Part Scores
                VStack(alignment: .leading, spacing: 16) {
                    Text("Part Scores")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ForEach(Array(testResult.parts.enumerated()), id: \.offset) { index, score in
                        HStack {
                            Text("Part \(index + 1)")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", score))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(scoreColor(score))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                
                // AI Feedback
                VStack(alignment: .leading, spacing: 12) {
                    Text("AI Feedback")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(testResult.overallFeedback)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                
                // Recommendations
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recommendations")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RecommendationRow(icon: "book.fill", text: "Practice advanced vocabulary daily", color: .blue)
                        RecommendationRow(icon: "waveform", text: "Work on pronunciation clarity", color: .orange)
                        RecommendationRow(icon: "timer", text: "Reduce speaking hesitations", color: .green)
                    }
                }
                
                Color.clear.frame(height: 100)
            }
            .padding(20)
        }
    }
    
    private var conversationAnalysisTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(testResult.conversations) { conversation in
                    ConversationCard(conversation: conversation)
                }
                
                Color.clear.frame(height: 100)
            }
            .padding(20)
        }
    }
    
    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 7.0...9.0: return .green
        case 6.0..<7.0: return .orange
        default: return .red
        }
    }
}


struct FeedbackScreen_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackScreen(testResult: TestResult(
             id: "1",
            date: Date(),
            bandScore: 7.5,
            duration: "14 min",
            parts: [6.5, 7.5, 8.0],
            overallFeedback: "Excellent fluency and coherence. Your vocabulary range is impressive.",
            conversations: []
        ))
    }
}
