import SwiftUI

struct HomeScreen: View {
    @State private var isStartingTest = false
    @State private var selectedTestResult: TestResult? = nil
    @State private var showFeedbackScreen = false
    
    let testResults = [
        TestResult(
            id: "1",
            date: Date().addingTimeInterval(-86400 * 2),
            bandScore: 7.5,
            duration: "14 min",
            parts: [6.5, 7.5, 8.0],
            overallFeedback: "Excellent fluency and coherence. Your vocabulary range is impressive, and you demonstrated good grammatical accuracy. Work on reducing minor hesitations in Part 1.",
            conversations: [
                Conversation(
                    part: 1,
                    question: "Tell me about your hometown.",
                    answer: "I come from a small town called Sylhet in Bangladesh. It's a beatiful place with lots of green hills and tea gardens. The people there are very friendly and hospitable. I've been living there for most of my life, and I really love the peaceful atmosphere.",
                    errors: [
                        ConversationError(word: "beatiful", correction: "beautiful", range: NSRange(location: 68, length: 8))
                    ]
                ),
                Conversation(
                    part: 2,
                    question: "Describe a memorable journey you have taken.",
                    answer: "I'd like to talk about a trip I took to the mountains last year. It was absolutely breathtaking experience. We hiked for about three hours through dense forests and rocky paths. The view from the top was incredible - we could see the entire valley below us. What made it even more special was that I went with my best friends, and we had such a great time together.",
                    errors: [
                        ConversationError(word: "breathtaking", correction: "a breathtaking", range: NSRange(location: 75, length: 12))
                    ]
                )
            ]
        ),
        TestResult(
            id: "2",
            date: Date().addingTimeInterval(-86400 * 5),
            bandScore: 6.5,
            duration: "12 min",
            parts: [6.0, 7.0, 6.5],
            overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
            conversations: [
                Conversation(
                    part: 1,
                    question: "What do you do for work or study?",
                    answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                    errors: [
                        ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                    ]
                )
            ]
        ),
        TestResult(
            id: "3",
            date: Date().addingTimeInterval(-86400 * 8),
            bandScore: 6.0,
            duration: "13 min",
            parts: [5.5, 6.0, 6.5],
            overallFeedback: "Adequate communication with some good ideas. Work on grammatical accuracy and expanding your range of vocabulary. Practice speaking more fluently without long pauses.",
            conversations: [
                Conversation(
                    part: 1,
                    question: "Do you like reading books?",
                    answer: "Yes, I do like reading books very much. I usually read fiction books because they are very entertaining. My favorite author is J.K. Rowling, she wrote the Harry Potter series. I thinks reading is a good way to improve vocabulary and imagination.",
                    errors: [
                        ConversationError(word: "thinks", correction: "think", range: NSRange(location: 156, length: 6))
                    ]
                )
            ]
        ),
        TestResult(
            id: "4",
            date: Date().addingTimeInterval(-86400 * 5),
            bandScore: 6.5,
            duration: "12 min",
            parts: [6.0, 7.0, 6.5],
            overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
            conversations: [
                Conversation(
                    part: 1,
                    question: "What do you do for work or study?",
                    answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                    errors: [
                        ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                    ]
                )
            ]
        ),
        TestResult(
            id: "5",
            date: Date().addingTimeInterval(-86400 * 5),
            bandScore: 6.5,
            duration: "12 min",
            parts: [6.0, 7.0, 6.5],
            overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
            conversations: [
                Conversation(
                    part: 1,
                    question: "What do you do for work or study?",
                    answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                    errors: [
                        ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                    ]
                )
            ]
        ),
        TestResult(
            id: "6",
            date: Date().addingTimeInterval(-86400 * 5),
            bandScore: 6.5,
            duration: "12 min",
            parts: [6.0, 7.0, 6.5],
            overallFeedback: "Good overall performance with clear communication. Focus on expanding your vocabulary and reducing repetitive phrases. Your pronunciation is generally clear.",
            conversations: [
                Conversation(
                    part: 1,
                    question: "What do you do for work or study?",
                    answer: "I am currently studying computer science at the university. It's a very intresting field because technology is always changing and evolving. I particularly enjoy programming and working with databases. After graduation, I hope to work in a tech company.",
                    errors: [
                        ConversationError(word: "intresting", correction: "interesting", range: NSRange(location: 65, length: 10))
                    ]
                )
            ]
        ),
    ]
    
    var averageScore: Double {
        let total = testResults.reduce(0) { $0 + $1.bandScore }
        return testResults.isEmpty ? 0 : total / Double(testResults.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Modern Header with Gradient
                    headerSection
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Hero Section - Start Test
                        heroSection
                        
                        // Quick Stats
                        quickStatsSection
                        
                        // Recent Tests
                        recentTestsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color(.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationBarHidden(true)
            .sheet(isPresented: $showFeedbackScreen) {
                if let selectedResult = selectedTestResult {
                    FeedbackScreen(testResult: selectedResult)
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            Color.clear
            
            // Header content
            HStack {
                Text("Practice IELTS Speaking")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
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
        .clipShape(
            RoundedRectangle(cornerRadius: 0)
                .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        )
    }
    
    private var heroSection: some View {
        VStack(spacing: 20) {
            // Main CTA Button
            Button(action: {
                isStartingTest = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isStartingTest = false
                }
            }) {
                ZStack {
                    // Gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue,
                            Color.purple
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Content
                    VStack(spacing: 12) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: "mic.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        // Text
                        VStack(spacing: 4) {
                            Text("Start Speaking Test")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Get AI-powered feedback instantly")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        // Test details
                        HStack(spacing: 20) {
                            Label("15 min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Label("3 Parts", systemImage: "list.number")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Label("AI Scoring", systemImage: "brain.head.profile")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.vertical, 30)
                }
            }
            .scaleEffect(isStartingTest ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isStartingTest)
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                // Average Score
                StatCard(
                    title: "Average Score",
                    value: String(format: "%.1f", averageScore),
                    subtitle: "Band Score",
                    color: .blue,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                // Total Tests
                StatCard(
                    title: "Tests Taken",
                    value: "\(testResults.count)",
                    subtitle: "Total",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                // Improvement
                StatCard(
                    title: "Improvement",
                    value: "+1.5",
                    subtitle: "This Month",
                    color: .orange,
                    icon: "arrow.up.circle.fill"
                )
            }
            
            ScoreBarChart(
                testResults: testResults,
            )

            
        }
    }
    
    private var recentTestsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Tests")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("View All") {
                    // Handle view all
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            }
            
            if testResults.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(testResults) { result in
                        ModernTestCard(result: result) {
                            selectedTestResult = result
                            showFeedbackScreen = true
                        }
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.badge.mic")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No tests yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Take your first speaking test to get AI feedback and track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct ModernTestCard: View {
    let result: TestResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.3), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: result.bandScore / 9.0)
                        .stroke(scoreColor, lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text(String(format: "%.1f", result.bandScore))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor)
                }
                
                // Test Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.date, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(result.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Label(result.duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("AI Feedback", systemImage: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var scoreColor: Color {
        switch result.bandScore {
        case 7.0...9.0: return .green
        case 6.0..<7.0: return .orange
        default: return .red
        }
    }
}

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

struct RecommendationRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct ConversationCard: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Part \(conversation.part)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                    )
                
                Spacer()
                
                Text("\(conversation.errors.count) error\(conversation.errors.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Question
            VStack(alignment: .leading, spacing: 8) {
                Text("Question:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(conversation.question)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
            
            // Answer with error highlighting
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Answer:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HighlightedText(text: conversation.answer, errors: conversation.errors)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
            
            // Errors
            if !conversation.errors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Corrections:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ForEach(conversation.errors, id: \.word) { error in
                        HStack {
                            Text(error.word)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .strikethrough()
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(error.correction)
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct HighlightedText: View {
    let text: String
    let errors: [ConversationError]
    
    var body: some View {
        Text(attributedString)
            .font(.body)
            .lineSpacing(4)
    }
    
    private var attributedString: AttributedString {
        var attributed = AttributedString(text)
        
        for error in errors {
            let startIndex = attributed.index(attributed.startIndex, offsetByCharacters: error.range.location)
            let endIndex = attributed.index(startIndex, offsetByCharacters: error.range.length)

            
            attributed[startIndex..<endIndex].foregroundColor = .red
            attributed[startIndex..<endIndex].backgroundColor = .red.opacity(0.2)
        }
        
        return attributed
    }
}

// MARK: - Data Models
struct TestResult: Identifiable {
    let id: String
    let date: Date
    let bandScore: Double
    let duration: String
    let parts: [Double]
    let overallFeedback: String
    let conversations: [Conversation]
}

struct Conversation: Identifiable {
    let id = UUID()
    let part: Int
    let question: String
    let answer: String
    let errors: [ConversationError]
}

struct ConversationError {
    let word: String
    let correction: String
    let range: NSRange
}

// MARK: - Previews
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
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
