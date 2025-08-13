import SwiftUI
import Supabase

struct HomeScreen: View {
    @State private var isStartingTest = false
    @State private var selectedTestResult: TestResult? = nil
    @State private var showFeedbackScreen = false
    @State private var showPreparationSheet = false
    @State private var showTestingView = false
    @State private var isLoading = false
    @State private var testQuestions: [Int: [QuestionItem]] = [:]
    @State private var navigationTrigger = false
    
    var averageScore: Double {
        let total = testResults.reduce(0) { $0 + $1.bandScore }
        return testResults.isEmpty ? 0 : total / Double(testResults.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    HomeHeaderSection()
                    
                    VStack(spacing: 24) {
                        HomeHeroSection(
                            isLoading: isLoading,
                            onStartTest: startTest
                        )
                        
                        TestNavigationOverlay(
                            isLoading: isLoading,
                            testQuestions: testQuestions,
                            showTestingView: $showTestingView,
                            navigationTrigger: $navigationTrigger
                        )
                        
                        QuickStatsSection(
                            averageScore: averageScore,
                            testResults: testResults
                        )
                        
                        InformationSection()
                        
                        RecentTestsSection(
                            testResults: testResults,
                            onTestSelected: selectTest
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showFeedbackScreen) {
                if let selectedResult = selectedTestResult {
                    FeedbackScreen(testResult: selectedResult)
                }
            }
        }
    }

    private func startTest() {
            print("HomeScreen: Start test button pressed")
            isLoading = true
            testQuestions = [:] // Clear previous questions
            navigationTrigger = false // Reset navigation trigger
            
            Task {
                do {
                    print("HomeScreen: Fetching test questions...")
                    testQuestions = try await TestService.shared.fetchTestQuestions()
                    
                    print("HomeScreen: Questions fetched successfully:")
                    for (part, items) in testQuestions {
                        print("Part \(part): \(items.count) questions")
                    }
                    
                    await MainActor.run {
                        isLoading = false
                        
                        // Ensure we have questions before navigating
                        if !testQuestions.isEmpty {
                            showTestingView = true
                            navigationTrigger = true
                            print("HomeScreen: Navigation triggered with \(testQuestions.count) question parts")
                        } else {
                            print("HomeScreen: ERROR - No questions fetched!")
                        }
                    }
                } catch {
                    print("❌ HomeScreen: Failed to fetch test: \(error)")
                    await MainActor.run {
                        isLoading = false
                    }
                }
            }
        }
        
    private func selectTest(_ result: TestResult) {
        selectedTestResult = result
        showFeedbackScreen = true
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ProgressView("Preparing test...")
            .frame(
                width: 200,
                height: 200,
                alignment: .center
            )
            .background(Color.white)
            .cornerRadius(12)
    }
}

struct TestNavigationOverlay: View {
    let isLoading: Bool
    let testQuestions: [Int: [QuestionItem]]
    @Binding var showTestingView: Bool
    @Binding var navigationTrigger: Bool
    
    var body: some View {
        NavigationLink(
            destination: destinationView,
            isActive: $showTestingView
        ) {
            EmptyView()
        }
        .hidden()
        .overlay {
            if isLoading {
                LoadingOverlay()
            }
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if navigationTrigger && !testQuestions.isEmpty {
            // Use the backend-enabled test simulator
            BackendEnabledTestSimulatorScreen(questions: testQuestions)
        } else {
            Text("Loading test...")
                .onAppear {
                    print("TestNavigationOverlay: Fallback view appeared - this indicates an issue")
                }
        }
    }
}

struct BackendEnabledTestSimulatorScreen: View {
    @StateObject private var testManager: TestSimulationManager
    @Environment(\.dismiss) private var dismiss
    @State private var showQuestions = true
    let questions: [Int: [QuestionItem]]
    
    init(questions: [Int: [QuestionItem]]) {
        self.questions = questions
        // Use the regular initializer
        _testManager = StateObject(wrappedValue: TestSimulationManager(questions: questions))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    TestHeaderView(
                        currentPhase: testManager.currentPhase,
                        currentPart: testManager.currentPart,
                        onDismiss: { dismiss() }
                    )

                    switch testManager.currentPhase {
                    case .preparation:
                        TestPreparationView(
                            onStartTest: testManager.startTestWithBackend // Use backend method
                        )
                    case .testing:
                        ExamTestView(
                            currentPart: testManager.currentPart,
                            currentQuestionText: testManager.currentQuestionText,
                            isExaminerSpeaking: testManager.isExaminerSpeaking,
                            isUserSpeaking: testManager.isUserSpeaking,
                            isRecording: testManager.isRecording,
                            recordingTime: testManager.recordingTime,
                            waveformData: testManager.audioPlayerManager.isPlaying ? testManager.generateVisualWaveformData(for: testManager.audioPlayerManager.currentPlaybackTime, duration: testManager.audioPlayerManager.currentAudioDuration, isSpeaking: testManager.isExaminerSpeaking) : Array(repeating: 0.0, count: 50),
                            userWaveformData: testManager.audioRecorderManager.isRecording ? testManager.generateUserVisualWaveformData(power: testManager.audioRecorderManager.averagePower) : Array(repeating: 0.0, count: 30))
                    case .completed:
                        if let backendResults = testManager.backendResults {
                            BackendResultsView(
                                testResults: backendResults,
                                localConversations: testManager.conversations
                            )
                        } else {
                            TestCompletedView(onViewResults: {
                                dismiss()
                            })
                        }
                    case .processing:
                        TestProcessingView(isProcessing: .constant(true))
                            .overlay(
                                VStack {
                                    if SupabaseService.shared.isProcessing {
                                        Text("AI is analyzing your responses...")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.top, 8)
                                        
                                        Text("This may take up to 2 minutes")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .opacity(0.7)
                                    }
                                }
                            )
                            .onAppear {
                                testManager.finalizeTest()
                            }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }

    
    private func generateVisualWaveformData(for currentTime: TimeInterval, duration: TimeInterval, isSpeaking: Bool) -> [Double] {
        guard isSpeaking && duration > 0 else { return Array(repeating: 0.0, count: 50) }
        let progress = currentTime / duration
        let activeBarCount = Int(progress * Double(50))
        var data = Array(repeating: 0.0, count: 50)
        for i in 0..<50 {
            if i < activeBarCount {
                data[i] = Double.random(in: 0.3...1.0)
            } else {
                data[i] = 0.1
            }
        }
        return data
    }

    private func generateUserVisualWaveformData(power: Float) -> [Double] {
        var data = Array(repeating: 0.0, count: 30)
        let normalizedPower = max(0.0, min(1.0, power))
        for i in 0..<30 {
            data[i] = Double(normalizedPower) * Double.random(in: 0.5...1.0)
        }
        return data
    }
}


class TestService {
    static let shared = TestService()
    private init() {}
    
    func fetchTestQuestions(testTemplateId: String = "550e8400-e29b-41d4-a716-446655440000") async throws -> [Int: [QuestionItem]] {
        print("🔍 Fetching questions for test template ID: \(testTemplateId)")
        
        // Fetch and decode into QuestionRow with correct column names
        let response = try await supabase
            .from("questions")
            .select()
            .eq("test_template_id", value: testTemplateId)
            .order("part_number", ascending: true)
            .order("question_order", ascending: true)
            .execute()
            .value as [QuestionRow]
        
//        print("📥 Fetched \(response.count) question rows from database")
//        
//        // Debug: Print first row structure
//        if let firstRow = response.first {
//            print("🔍 First row structure:")
//            print("   ID: \(firstRow.id) (type: \(type(of: firstRow.id)))")
//            print("   Part: \(firstRow.part)")
//            print("   Order: \(firstRow.order)")
//            print("   Audio URL: \(firstRow.audio_url)")
//        }
        
        var parts: [Int: [QuestionItem]] = [:]
        
        for row in response {
            do {
                print("📥 Processing question ID \(row.id): \(row.question_text.prefix(30))...")
                
                // Download audio file from Supabase Storage
                let audioData = try await supabase.storage
                    .from("audio-question-set")
                    .download(path: row.audio_url)
                
                print("✅ Downloaded audio for question \(row.id): \(audioData.count) bytes")
                
                let item = QuestionItem(
                    id: row.id,  // Database ID is already a UUID string
                    part: row.part,
                    order: row.order,
                    questionText: row.question_text,
                    audioFile: audioData
                )
                
                let normalizedPart = row.part - 1  // Convert 1,2,3 to 0,1,2
                parts[normalizedPart, default: []].append(item)
                
                print("✅ Added question \(row.id) to part \(normalizedPart)")
                
            } catch {
                print("❌ Failed to process question \(row.id): \(error.localizedDescription)")
                // Continue with other questions instead of failing completely
            }
        }
        
        print("📊 Final question distribution:")
        for (part, items) in parts.sorted(by: { $0.key < $1.key }) {
            print("   Part \(part): \(items.count) questions")
        }
        
        return parts
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
