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
    
//    private func startTest() {
//        isLoading = true
//        Task {
//            do {
//                testQuestions = try await TestService.shared.fetchTestQuestions(testId: 1)
//                isLoading = false
//                showTestingView = true
//                
//                let part1Questions = testQuestions[0] ?? []
//                let part2Questions = testQuestions[1] ?? []
//                let part3Questions = testQuestions[2] ?? []
//                 print("\(part1Questions) \(part2Questions) \(part3Questions)")
//            } catch {
//                print("❌ Failed to fetch test: \(error)")
//                isLoading = false
//            }
//        }
//    }
//    
//    private func selectTest(_ result: TestResult) {
//        selectedTestResult = result
//        showFeedbackScreen = true
//    }
    private func startTest() {
            print("HomeScreen: Start test button pressed")
            isLoading = true
            testQuestions = [:] // Clear previous questions
            navigationTrigger = false // Reset navigation trigger
            
            Task {
                do {
                    print("HomeScreen: Fetching test questions...")
                    testQuestions = try await TestService.shared.fetchTestQuestions(testId: 1)
                    
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




// MARK: - Test Detail Label
struct TestDetailLabel: View {
    let text: String
    let icon: String
    
    var body: some View {
        Label(text, systemImage: icon)
            .font(.custom("Fredoka-Regular", size: 14))
            .foregroundColor(.white.opacity(0.8))
    }
}

// MARK: - Test Navigation Overlay
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
            TestSimulatorScreen(questions: testQuestions)
        } else {
            // Fallback view - this shouldn't happen if everything works correctly
            Text("Loading test...")
                .onAppear {
                    print("TestNavigationOverlay: Fallback view appeared - this indicates an issue")
                }
        }
    }
}

// MARK: - Loading Overlay
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

// MARK: - Test Service (Extracted Business Logic)
class TestService {
    static let shared = TestService()
    private init() {}
    
    func fetchTestQuestions(testId: Int = 1) async throws -> [Int: [QuestionItem]] {
        // Fetch and decode into QuestionRow
        let response = try await supabase
            .from("questions")
            .select()
            .eq("test_id", value: testId)
            .order("part", ascending: true)
            .order("order", ascending: true)
            .execute()
            .value as [QuestionRow]
        
        print(response.count)
        
        var parts: [Int: [QuestionItem]] = [:]
        
        for row in response {
            do {
                // Download audio file from Supabase Storage
                let audioData = try await supabase.storage
                    .from("audio-question-set")
                    .download(path: row.audio_url)
                
                let item = QuestionItem(
                    part: row.part,
                    order: row.order,
                    questionText: row.question_text,
                    audioFile: audioData
                )
                
//                print(item)
                
                let normalizedPart = row.part - 1
                parts[normalizedPart, default: []].append(item)
            } catch {
                print("⚠️ Failed to download audio: \(row.audio_url) - \(error.localizedDescription)")
            }
        }
        return parts
    }
}

// MARK: - Previews
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
