import SwiftUI
import Supabase

struct QuestionItem {
    let order: Int
    let questionText: String
    let audioFile: Data
}

struct HomeScreen: View {
    @State private var isStartingTest = false
    @State private var selectedTestResult: TestResult? = nil
    @State private var showFeedbackScreen = false
    @State private var showPreparationSheet = false
    @State private var showTestingView = false
    @State private var isLoading = false
    @State private var testQuestions: [[QuestionItem]] = []
    
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
                        
                        NavigationLink(
                            destination: TestSimulatorScreen(
                                questions: testQuestions
                            ),
                            isActive: $isLoading
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        .overlay {
                            if isLoading {
                                ZStack {
                                    Color.black
                                        .opacity(0.3)
                                        .ignoresSafeArea()
                                    
                                    ProgressView("Preparing test...")
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
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
            // CTA button
//            NavigationLink(destination: TestSimulatorScreen()) {
//
//            }
            Button(action: {
                Task {
                    // await fetchTestQuestions()
                }
            }, label: {
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
            })
            .disabled(isLoading)
            .scaleEffect(isStartingTest ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isStartingTest)
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        
        
        
    }
    
    func fetchTestQuestions(forPart part: Int, testId: Int ) async {
        isLoading = true
        defer { isLoading = false }
        
        var part1 : [QuestionItem] = []
        var part2 : [QuestionItem] = []
        var part3 : [QuestionItem] = []
        
        do {
            let questions = try await supabase
                    .from("questions")
                    .select("*")
                    .eq("test_id", value: testId)
                    .eq("part", value: part)
                    .order("order", ascending: true)
                    .execute()
                    .value as! [[String: Any]]

            
            
            for question in questions {
                let questionText = question["question_text"] as? String ?? ""
                let audioPath = question["audio_url"] as? String ?? ""
                
                let part = question["part"] as? Int ?? 0
                let order = question["order"] as? Int ?? 0
                let data = try await supabase.storage
                    .from("audio-question-set")
                    .download(path: audioPath)
                
                if part == 1 {
                    part1
                        .append(
                            QuestionItem(
                                order: order,
                                questionText: questionText,
                                audioFile: data
                            )
                        )
                } else if part == 2 {
                    part2
                        .append(
                            QuestionItem(
                                order: order,
                                questionText: questionText,
                                audioFile: data
                            )
                        )
                } else if part == 3 {
                    part3
                        .append(
                            QuestionItem(
                                order: order,
                                questionText: questionText,
                                audioFile: data
                            )
                        )
                }
            }
            
            
            
        } catch {
            print("Error downloading test: \(error)")
        }
        testQuestions = [part1, part2, part3]
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


// MARK: - Previews
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}

//
//import SwiftUI
//import Supabase // Add this import
//
//// Fixed QuestionItem struct
//struct QuestionItem {
//    let order: Int
//    let questionText: String
//    let audioData: Data // Changed from Audio to Data
//}
//
//// Add missing model definitions
//struct TestResult: Identifiable {
//    let id: String
//    let date: Date
//    let bandScore: Double
//    let duration: String
//    let parts: [Double]
//    let overallFeedback: String
//    let conversations: [Conversation]
//}
//
//struct Conversation {
//    let part: Int
//    let question: String
//    let answer: String
//    let errors: [ConversationError]
//}
//
//struct ConversationError {
//    let word: String
//    let correction: String
//    let range: NSRange
//}
//
//struct HomeScreen: View {
//    @State private var isStartingTest = false
//    @State private var selectedTestResult: TestResult? = nil
//    @State private var showFeedbackScreen = false
//    @State private var showPreparationSheet = false
//    @State private var showTestingView = false
//    @State private var isLoading = false
//    @State private var downloadedQuestions: [QuestionItem] = []
//    @State private var testQuestions: [[QuestionItem]] = [] // Store the downloaded questions
//    @State private var navigateToTest = false
//    
//    // Initialize Supabase client (you'll need to add your URL and key)
//    let supabase = SupabaseClient(
//        supabaseURL: URL(string: "YOUR_SUPABASE_URL")!,
//        supabaseKey: "YOUR_SUPABASE_ANON_KEY"
//    )
//    
//    let testResults = [
//        TestResult(
//            id: "1",
//            date: Date().addingTimeInterval(-86400 * 2),
//            bandScore: 7.5,
//            duration: "14 min",
//            parts: [6.5, 7.5, 8.0],
//            overallFeedback: "Excellent fluency and coherence. Your vocabulary range is impressive, and you demonstrated good grammatical accuracy. Work on reducing minor hesitations in Part 1.",
//            conversations: [
//                Conversation(
//                    part: 1,
//                    question: "Tell me about your hometown.",
//                    answer: "I come from a small town called Sylhet in Bangladesh. It's a beatiful place with lots of green hills and tea gardens. The people there are very friendly and hospitable. I've been living there for most of my life, and I really love the peaceful atmosphere.",
//                    errors: [
//                        ConversationError(word: "beatiful", correction: "beautiful", range: NSRange(location: 68, length: 8))
//                    ]
//                ),
//                Conversation(
//                    part: 2,
//                    question: "Describe a memorable journey you have taken.",
//                    answer: "I'd like to talk about a trip I took to the mountains last year. It was absolutely breathtaking experience. We hiked for about three hours through dense forests and rocky paths. The view from the top was incredible - we could see the entire valley below us. What made it even more special was that I went with my best friends, and we had such a great time together.",
//                    errors: [
//                        ConversationError(word: "breathtaking", correction: "a breathtaking", range: NSRange(location: 75, length: 12))
//                    ]
//                )
//            ]
//        ),
//        // ... other test results
//    ]
//    
//    var averageScore: Double {
//        let total = testResults.reduce(0) { $0 + $1.bandScore }
//        return testResults.isEmpty ? 0 : total / Double(testResults.count)
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 0) {
//                    // Modern Header with Gradient
//                    headerSection
//                    
//                    // Main Content
//                    VStack(spacing: 24) {
//                        // Hero Section - Start Test
//                        heroSection
//                        
//                        // Navigation link for test simulator
//                        NavigationLink(
//                            destination: TestSimulatorScreen(questions: testQuestions),
//                            isActive: $navigateToTest
//                        ) {
//                            EmptyView()
//                        }
//                        .hidden()
//                        
//                        // Loading overlay
//                        if isLoading {
//                            ZStack {
//                                Color.black
//                                    .opacity(0.3)
//                                    .ignoresSafeArea()
//                                
//                                ProgressView("Preparing test...")
//                                    .padding()
//                                    .background(Color.white)
//                                    .cornerRadius(12)
//                            }
//                        }
//                        
//                        // Quick Stats
//                        quickStatsSection
//                        
//                        // Recent Tests
//                        recentTestsSection
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    .padding(.bottom, 100)
//                }
//            }
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [
//                        Color.blue.opacity(0.1),
//                        Color.purple.opacity(0.05),
//                        Color(.systemBackground)
//                    ]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//            )
//            .navigationBarHidden(true)
//            .sheet(isPresented: $showFeedbackScreen) {
//                if let selectedResult = selectedTestResult {
//                    FeedbackScreen(testResult: selectedResult)
//                }
//            }
//        }
//    }
//    
//    private var headerSection: some View {
//        VStack(spacing: 0) {
//            Color.clear
//            
//            // Header content
//            HStack {
//                Text("Practice IELTS Speaking")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 30)
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
//        .clipShape(
//            RoundedRectangle(cornerRadius: 0)
//                .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
//        )
//    }
//    
//    private var heroSection: some View {
//        VStack(spacing: 20) {
//            // Fixed CTA button
//            Button(action: {
//                Task {
//                    await startTest()
//                }
//            }, label: {
//                ZStack {
//                    // Gradient background
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color.blue,
//                            Color.purple
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    
//                    // Content
//                    VStack(spacing: 12) {
//                        // Icon
//                        ZStack {
//                            Circle()
//                                .fill(Color.white.opacity(0.2))
//                                .frame(width: 60, height: 60)
//                            
//                            Image(systemName: "mic.fill")
//                                .font(.title)
//                                .foregroundColor(.white)
//                        }
//                        
//                        // Text
//                        VStack(spacing: 4) {
//                            Text("Start Speaking Test")
//                                .font(.title2)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                            
//                            Text("Get AI-powered feedback instantly")
//                                .font(.subheadline)
//                                .foregroundColor(.white.opacity(0.9))
//                        }
//                        
//                        // Test details
//                        HStack(spacing: 20) {
//                            Label("15 min", systemImage: "clock")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.8))
//                            
//                            Label("3 Parts", systemImage: "list.number")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.8))
//                            
//                            Label("AI Scoring", systemImage: "brain.head.profile")
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                    }
//                    .padding(.vertical, 30)
//                }
//            })
//            .disabled(isLoading)
//            .scaleEffect(isStartingTest ? 0.95 : 1.0)
//            .animation(.easeInOut(duration: 0.2), value: isStartingTest)
//            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
//        }
//    }
//    
//    // Fixed function to start test
//    private func startTest() async {
//        isStartingTest = true
//        isLoading = true
//        
//        do {
//            // Download questions for a specific test (you can make testId dynamic)
//            let questions = try await fetchTestQuestions(testId: 1)
//            testQuestions = questions
//            
//            // Navigate to test simulator
//            await MainActor.run {
//                isLoading = false
//                isStartingTest = false
//                navigateToTest = true
//            }
//        } catch {
//            await MainActor.run {
//                isLoading = false
//                isStartingTest = false
//                // Handle error - maybe show an alert
//                print("Failed to start test: \(error)")
//            }
//        }
//    }
//    
//    // Fixed fetchTestQuestions function
//    func fetchTestQuestions(testId: Int) async throws -> [[QuestionItem]] {
//        do {
//            let response = try await supabase
//                .from("questions")
//                .select("*")
//                .eq("test_id", value: testId)
//                .order("order", ascending: true)
//                .execute()
//            
//            guard let questions = response.value as? [[String: Any]] else {
//                throw NSError(domain: "DataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
//            }
//            
//            var part1: [QuestionItem] = []
//            var part2: [QuestionItem] = []
//            var part3: [QuestionItem] = []
//            
//            for question in questions {
//                guard let questionText = question["question_text"] as? String,
//                      let audioPath = question["audio_url"] as? String,
//                      let part = question["part"] as? Int,
//                      let order = question["order"] as? Int else {
//                    continue
//                }
//                
//                // Download audio data
//                let audioData = try await supabase.storage
//                    .from("audio-question-set")
//                    .download(path: audioPath)
//                
//                let questionItem = QuestionItem(
//                    order: order,
//                    questionText: questionText,
//                    audioData: audioData
//                )
//                
//                switch part {
//                case 1:
//                    part1.append(questionItem)
//                case 2:
//                    part2.append(questionItem)
//                case 3:
//                    part3.append(questionItem)
//                default:
//                    break
//                }
//            }
//            
//            // Sort by order
//            part1.sort { $0.order < $1.order }
//            part2.sort { $0.order < $1.order }
//            part3.sort { $0.order < $1.order }
//            
//            return [part1, part2, part3]
//        } catch {
//            print("Error downloading test: \(error)")
//            throw error
//        }
//    }
//    
//    private var quickStatsSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Your Progress")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .foregroundColor(.primary)
//            
//            HStack(spacing: 16) {
//                // Average Score
//                StatCard(
//                    title: "Average Score",
//                    value: String(format: "%.1f", averageScore),
//                    subtitle: "Band Score",
//                    color: .blue,
//                    icon: "chart.line.uptrend.xyaxis"
//                )
//                
//                // Total Tests
//                StatCard(
//                    title: "Tests Taken",
//                    value: "\(testResults.count)",
//                    subtitle: "Total",
//                    color: .green,
//                    icon: "checkmark.circle.fill"
//                )
//                
//                // Improvement
//                StatCard(
//                    title: "Improvement",
//                    value: "+1.5",
//                    subtitle: "This Month",
//                    color: .orange,
//                    icon: "arrow.up.circle.fill"
//                )
//            }
//            
//            ScoreBarChart(
//                testResults: testResults
//            )
//        }
//    }
//    
//    private var recentTestsSection: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Recent Tests")
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                Button("View All") {
//                    // Handle view all
//                }
//                .font(.subheadline)
//                .fontWeight(.medium)
//                .foregroundColor(.blue)
//            }
//            
//            if testResults.isEmpty {
//                emptyStateView
//            } else {
//                LazyVStack(spacing: 12) {
//                    ForEach(testResults) { result in
//                        ModernTestCard(result: result) {
//                            selectedTestResult = result
//                            showFeedbackScreen = true
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 16) {
//            Image(systemName: "waveform.badge.mic")
//                .font(.system(size: 60))
//                .foregroundColor(.gray.opacity(0.6))
//            
//            Text("No tests yet")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .foregroundColor(.primary)
//            
//            Text("Take your first speaking test to get AI feedback and track your progress")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(.vertical, 40)
//        .frame(maxWidth: .infinity)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemGray6))
//        )
//    }
//}
