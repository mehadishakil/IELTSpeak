////
////  FeedbackScreen.swift
////  IELTSpeak
////
////  Created by Mehadi Hasan on 13/7/25.
////
//
//import SwiftUI
//
//// MARK: - Feedback Screen
//struct FeedbackScreen: View {
//    let testResult: TestResult
//    @Environment(\.dismiss) private var dismiss
//    @State private var selectedTab = 0
//    
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                // Header
//                headerSection
//                
//                // Tab Selection
//                tabSelector
//                
//                // Content
//                TabView(selection: $selectedTab) {
//                    // AI Feedback Tab
//                    aiFeedbackTab
//                        .tag(0)
//                    
//                    // Conversation Analysis Tab
//                    conversationAnalysisTab
//                        .tag(1)
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//            }
//            .background(Color(.systemBackground))
//            .navigationBarHidden(true)
//        }
//    }
//    
//    private var headerSection: some View {
//        VStack(spacing: 16) {
//            // Top bar
//            HStack {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title2)
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                
//                Spacer()
//                
//                Text("Test Feedback")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//                
//                Spacer()
//                
//                Button(action: {}) {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(.title2)
//                        .foregroundColor(.white.opacity(0.8))
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 44)
//            
//            // Score Display
//            VStack(spacing: 8) {
//                Text("Overall Band Score")
//                    .font(.subheadline)
//                    .foregroundColor(.white.opacity(0.8))
//                
//                Text(String(format: "%.1f", testResult.bandScore))
//                    .font(.system(size: 48, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                
//                Text(testResult.date, style: .date)
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.7))
//            }
//            .padding(.bottom, 20)
//        }
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.blue.opacity(0.8),
//                    Color.purple.opacity(0.6)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//        )
//    }
//    
//    private var tabSelector: some View {
//        HStack(spacing: 0) {
//            ForEach(0..<2) { index in
//                Button(action: { selectedTab = index }) {
//                    VStack(spacing: 8) {
//                        Text(index == 0 ? "AI Feedback" : "Conversation")
//                            .font(.subheadline)
//                            .fontWeight(.medium)
//                            .foregroundColor(selectedTab == index ? .blue : .secondary)
//                        
//                        Rectangle()
//                            .fill(selectedTab == index ? Color.blue : Color.clear)
//                            .frame(height: 2)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//            }
//        }
//        .padding(.horizontal, 20)
//        .background(Color(.systemBackground))
//    }
//    
//    private var aiFeedbackTab: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Part Scores
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Part Scores")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                    
//                    ForEach(Array(testResult.parts.enumerated()), id: \.offset) { index, score in
//                        HStack {
//                            Text("Part \(index + 1)")
//                                .font(.subheadline)
//                                .foregroundColor(.primary)
//                            
//                            Spacer()
//                            
//                            Text(String(format: "%.1f", score))
//                                .font(.subheadline)
//                                .fontWeight(.semibold)
//                                .foregroundColor(scoreColor(score))
//                        }
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 16)
//                        .background(
//                            RoundedRectangle(cornerRadius: 8)
//                                .fill(Color(.systemGray6))
//                        )
//                    }
//                }
//                
//                // AI Feedback
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("AI Feedback")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                    
//                    Text(testResult.overallFeedback)
//                        .font(.body)
//                        .foregroundColor(.primary)
//                        .lineSpacing(4)
//                        .padding(16)
//                        .background(
//                            RoundedRectangle(cornerRadius: 12)
//                                .fill(Color.blue.opacity(0.1))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
//                                )
//                        )
//                }
//                
//                // Recommendations
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Recommendations")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        RecommendationRow(icon: "book.fill", text: "Practice advanced vocabulary daily", color: .blue)
//                        RecommendationRow(icon: "waveform", text: "Work on pronunciation clarity", color: .orange)
//                        RecommendationRow(icon: "timer", text: "Reduce speaking hesitations", color: .green)
//                    }
//                }
//                
//                Color.clear.frame(height: 100)
//            }
//            .padding(20)
//        }
//    }
//    
//    private var conversationAnalysisTab: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                ForEach(testResult.conversations) { conversation in
//                    ConversationCard(conversation: conversation)
//                }
//                
//                Color.clear.frame(height: 100)
//            }
//            .padding(20)
//        }
//    }
//    
//    private func scoreColor(_ score: Double) -> Color {
//        switch score {
//        case 7.0...9.0: return .green
//        case 6.0..<7.0: return .orange
//        default: return .red
//        }
//    }
//}
//
//
//struct FeedbackScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        FeedbackScreen(testResult: TestResult(
//             id: "1",
//            date: Date(),
//            bandScore: 7.5,
//            duration: "14 min",
//            parts: [6.5, 7.5, 8.0],
//            overallFeedback: "Excellent fluency and coherence. Your vocabulary range is impressive.",
//            conversations: []
//        ))
//    }
//}

import SwiftUI

// Assuming TestResult, Conversation, ConversationError, HighlightedText,
// and RecommendationRow structs are defined elsewhere as in previous examples.

struct FeedbackScreen: View {
    let testResult: TestResult
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @Namespace private var animationNamespace
    private var groupedConversations: [Int: [Conversation]] {
        Dictionary(grouping: testResult.conversations) { $0.part }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection

                tabSelector_Icons
                
                TabView(selection: $selectedTab) {
                    aiFeedbackTab
                        .tag(0)
                    conversationAnalysisTab
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
        }
    }

    private var headerSection: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Text("Test Feedback")
                    .font(.title3)
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(20)

            VStack(spacing: 4) {
                Text("Overall Band Score")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                    .fontDesign(.rounded)
                Text(String(format: "%.1f", testResult.bandScore))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(testResult.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .fontDesign(.rounded)
            }
            .padding(.bottom, 30)
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

    // REDESIGNED TAB SELECTOR
//    private var tabSelector: some View {
//        HStack(spacing: 12) {
//            ForEach(0..<2) { index in
//                Button(action: {
//                    selectedTab = index
//                    // Optional: Add haptic feedback
//                    // UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                }) {
//                    Text(index == 0 ? "AI Feedback" : "Conversation")
//                        .font(.subheadline)
//                        .fontWeight(selectedTab == index ? .bold : .medium) // Bold for selected
//                        .foregroundColor(selectedTab == index ? .white : .secondary) // White text on selected
//                        .padding(.vertical, 10)
//                        .padding(.horizontal, 20)
//                        .background(
//                            Capsule() // Capsule shape for selected tab
//                                .fill(selectedTab == index ? Color.blue : Color.clear)
//                                .animation(.spring(), value: selectedTab) // Smooth animation
//                        )
//                }
//                .frame(maxWidth: .infinity) // Ensures buttons take equal width
//            }
//        }
//        .padding(.vertical, 8) // Padding around the entire tab bar
//        .padding(.horizontal, 15) // Horizontal padding from screen edges
//        .background(Color(.systemGray6).opacity(0.9)) // A subtle background for the tab bar
//        .cornerRadius(30) // Rounded corners for the entire tab bar background
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3) // Light shadow
//        .padding(.horizontal, 20) // Overall padding for the tab bar from the screen edges
//        .offset(y: -20) // Lift it up slightly to overlap the gradient header
//    }
    
//    private var tabSelector_UnderlineEnhanced: some View {
//        HStack(spacing: 0) {
//            ForEach(0..<2) { index in
//                Button(action: { selectedTab = index }) {
//                    VStack(spacing: 6) { // Add spacing for underline
//                        Text(index == 0 ? "AI Feedback" : "Conversation")
//                            .font(.subheadline)
//                            .fontWeight(selectedTab == index ? .bold : .medium)
//                            .foregroundColor(selectedTab == index ? .blue : .secondary) // Highlight active text
//                        if selectedTab == index {
//                            Capsule() // Use a Capsule for the underline for rounded ends
//                                .fill(Color.blue)
//                                .frame(height: 3) // Thicker underline
//                                .matchedGeometryEffect(id: "underline", in: animationNamespace) // For smooth animation
//                        } else {
//                            Capsule()
//                                .fill(Color.clear)
//                                .frame(height: 3) // Placeholder for unselected
//                        }
//                    }
//                }
//                .frame(maxWidth: .infinity)
//            }
//        }
//        .padding(.top, 8) // Padding from the top
//        .background(Color(.systemGray6)) // Solid background for the tab bar
//        .cornerRadius(15) // Subtle corner radius for the whole bar
//        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
//        .padding(.horizontal, 20)
//        .offset(y: -20)
//    }
    // You'll need to add @Namespace private var animationNamespace somewhere in your View


    
    private var tabSelector_Icons: some View {
        HStack(spacing: 0) {
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "lightbulb.fill") // Icon for AI Feedback
                        .font(.callout)
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                    Text("Feedback")
                        .font(.caption)
                        .fontWeight(selectedTab == 0 ? .bold : .regular)
                        .foregroundColor(selectedTab == 0 ? .blue : .secondary)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(selectedTab == 0 ? Color.blue.opacity(0.1) : Color.clear)
                .cornerRadius(8)
            }

            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "message.fill") // Icon for Conversation
                        .font(.callout)
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                    Text("Conversations")
                        .font(.caption)
                        .fontWeight(selectedTab == 1 ? .bold : .regular)
                        .foregroundColor(selectedTab == 1 ? .blue : .secondary)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(selectedTab == 1 ? Color.blue.opacity(0.2) : Color.clear)
                .cornerRadius(8)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        .padding(.horizontal, 20)
        .offset(y: -20)
    }
    // You'll need to add @Namespace private var animationNamespace somewhere in your View
    
    
//    private var tabSelector_Segmented: some View {
//        HStack(spacing: 0) {
//            ForEach(0..<2) { index in
//                Button(action: { selectedTab = index }) {
//                    Text(index == 0 ? "AI Feedback" : "Conversation")
//                        .font(.subheadline)
//                        .fontWeight(.medium) // Keep consistent weight
//                        .foregroundColor(selectedTab == index ? .accentColor : .secondary) // Text color based on selection
//                        .frame(maxWidth: .infinity) // Each segment fills available width
//                        .padding(.vertical, 8)
//                        .background(
//                            ZStack {
//                                if selectedTab == index {
//                                    Capsule() // Or RoundedRectangle
//                                        .fill(Color.white) // White background for selected segment
//                                        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1) // Inner shadow
//                                        .matchedGeometryEffect(id: "segment", in: animationNamespace)
//                                }
//                            }
//                        )
//                }
//            }
//        }
//        .background(Capsule().fill(Color(.systemGray5))) // Darker background for the entire control
//        .padding(.horizontal, 20)
//        .offset(y: -20)
//    }
    // You'll need to add @Namespace private var animationNamespace somewhere in your View
    
    
    private var aiFeedbackTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Part Scores
                VStack(alignment: .leading, spacing: 16) {
                    Text("Criteria Scores")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    ForEach(testResult.criteriaScores.sorted(by: { $0.key < $1.key }), id: \.key) { criterion, score in
                        HStack {
                            Text(criterion)
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
            .padding(24)
            .offset(y: -20)
        }
    }


    private var conversationAnalysisTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(groupedConversations.keys.sorted(), id: \.self) { partNumber in
                    if let conversations = groupedConversations[partNumber] {
                        PartConversationCard(partNumber: partNumber, conversationsInPart: conversations)
                    }
                }
                .padding(.top, 12)
                Color.clear.frame(height: 100)
            }
            .padding(20)
            .offset(y: -20) // Compensate for the tab bar lift to avoid cutting off content
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

