
import Foundation
import AVFoundation
import Combine
import SwiftUI
import Speech



class TestSimulationManager: ObservableObject {
    @Published var currentPhase: TestPhase = .preparation
    @Published var currentPart: Int = 1
    @Published var currentQuestionIndex: Int = 0
    @Published var isExaminerSpeaking: Bool = false
    @Published var isUserSpeaking: Bool = false
    @Published var isRecording: Bool = false
    @Published var recordingTime: TimeInterval = 0
    @Published var part2PreparationTimeRemaining: TimeInterval = 60
    @Published var part2SpeakingTimeRemaining: TimeInterval = 120
    @Published var currentQuestionText: String = ""
    @Published var errorMessage: String?
    @Published var backendResults: TestResults?
    @Published var isUploadingResponses = false
    private var questionIds: [String] = [] // Store question IDs from backend
    private var questionIdMapping: [String: String] = [:]

    let audioPlayerManager = AudioPlayerManager()
    let audioRecorderManager = AudioRecorderManager()
    let speechRecognizerManager = SpeechRecognizerManager()

    var conversations: [Conversation] = []
    private var currentRecordedAudioURL: URL?
    private var currentQuestionStartTime: Date?
    private var preparationTimer: Timer?
    private var part2SpeakingTimer: Timer?
    private var questions: [Int: [QuestionItem]]
    private var cancellables = Set<AnyCancellable>()

    init(questions: [Int: [QuestionItem]]) {
        self.questions = questions
        
        print("TestSimulationManager Init - Questions structure:")
                for (part, items) in questions {
                    print("Part \(part): \(items.count) questions")
                    for (index, item) in items.enumerated() {
                        print("  Q\(index + 1): \(item.questionText.prefix(50))... (ID: \(item.id))")
                    }
                }
        
        setupBindings()
        buildQuestionIdMapping()  // Build question ID mapping on initialization
    }

    private func setupBindings() {
        audioPlayerManager.$isPlaying
            .assign(to: \.isExaminerSpeaking, on: self)
            .store(in: &cancellables)
        
        audioRecorderManager.$isRecording
            .assign(to: \.isRecording, on: self)
            .store(in: &cancellables)
        
        audioRecorderManager.$recordingTime
            .assign(to: \.recordingTime, on: self)
            .store(in: &cancellables)
        
        speechRecognizerManager.$isSpeechDetected
            .assign(to: \.isUserSpeaking, on: self)
            .store(in: &cancellables)
        
        speechRecognizerManager.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.errorMessage = "Speech Recognition Error: \(error)"
                print("TestSimulationManager: Speech Recognition Error: \(error)")
            }
            .store(in: &cancellables)
    }
    
    func startTest() {
        print("TestSimulationManager: startTest() called")
        print("Current questions keys: \(Array(questions.keys).sorted())")
        
        currentPhase = .testing
        
        // Initialize backend session first
        Task {
            await initializeBackendSession()
            
            await MainActor.run {
                requestAudioAndSpeechPermissions { [weak self] success in
                    if success {
                        print("TestSimulationManager: Permissions granted. Starting conversation flow.")
                        self?.startConversationFlow()
                    } else {
                        self?.errorMessage = "Microphone and Speech Recognition permissions are required."
                        self?.currentPhase = .preparation
                    }
                }
            }
        }
    }
    
    private func requestAudioAndSpeechPermissions(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { microphoneGranted in
            SFSpeechRecognizer.requestAuthorization { speechGranted in
                DispatchQueue.main.async {
                    if microphoneGranted && speechGranted == .authorized {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }

    func startConversationFlow() {
            print("TestSimulationManager: startConversationFlow() called")
            print("Current phase: \(currentPhase), part: \(currentPart), questionIndex: \(currentQuestionIndex)")
            print("Available question parts: \(Array(questions.keys).sorted())")
            
            guard currentPhase == .testing else {
                print("TestSimulationManager: Not in testing phase, returning")
                return
            }

            audioRecorderManager.stopRecording()
            speechRecognizerManager.stopSpeechRecognition()
            audioPlayerManager.stopAudio()
            part2SpeakingTimer?.invalidate()
            preparationTimer?.invalidate()
            print("TestSimulationManager: Cleaned up previous states.")

            if currentPart == 1 {
                print("Starting Part 1 - Questions available:")
                if let part1Questions = questions[0] {
                    print("Part 1 has \(part1Questions.count) questions")
                    for (index, question) in part1Questions.enumerated() {
                        print("  Q\(index + 1): \(question.questionText.prefix(30))...")
                    }
                    
                    guard currentQuestionIndex < part1Questions.count else {
                        print("TestSimulationManager: Part 1 finished. Moving to Part 2.")
                        currentPart = 2
                        currentQuestionIndex = 0
                        startConversationFlow()
                        return
                    }
                    
                    let question = part1Questions[currentQuestionIndex]
                    currentQuestionText = question.questionText
                    print("TestSimulationManager: Part 1, Question \(currentQuestionIndex + 1): Playing examiner audio for '\(currentQuestionText)'")
                    playExaminerQuestion(question.audioFile, part: currentPart, questionText: question.questionText, silenceDuration: 2.0)
                } else {
                    print("TestSimulationManager: ERROR - No Part 1 questions found!")
                    print("Available keys in questions dictionary: \(Array(questions.keys))")
                    errorMessage = "No Part 1 questions available"
                    currentPhase = .processing
                    return
                }

            } else if currentPart == 2 {
                print("Starting Part 2 - Questions available:")
                if let part2Questions = questions[1] {
                    print("Part 2 has \(part2Questions.count) questions")
                    
                    guard !part2Questions.isEmpty else {
                        print("TestSimulationManager: Part 2 finished or no questions. Moving to Part 3.")
                        currentPart = 3
                        currentQuestionIndex = 0
                        startConversationFlow()
                        return
                    }
                    
                    let cueCard = part2Questions[currentQuestionIndex]
                    currentQuestionText = cueCard.questionText
                    print("TestSimulationManager: Part 2: Playing cue card audio for '\(currentQuestionText.prefix(30))...'")
                    playExaminerQuestion(cueCard.audioFile, part: currentPart, questionText: cueCard.questionText) { [weak self] in
                        self?.startPart2Preparation()
                    }
                } else {
                    print("TestSimulationManager: ERROR - No Part 2 questions found!")
                    currentPart = 3
                    currentQuestionIndex = 0
                    startConversationFlow()
                    return
                }

            } else if currentPart == 3 {
                print("Starting Part 3 - Questions available:")
                if let part3Questions = questions[2] {
                    print("Part 3 has \(part3Questions.count) questions")
                    
                    guard currentQuestionIndex < part3Questions.count else {
                        print("TestSimulationManager: Part 3 finished. Moving to Processing.")
                        currentPhase = .processing
                        return
                    }
                    
                    let question = part3Questions[currentQuestionIndex]
                    currentQuestionText = question.questionText
                    print("TestSimulationManager: Part 3, Question \(currentQuestionIndex + 1): Playing examiner audio for '\(currentQuestionText.prefix(30))...'")
                    playExaminerQuestion(question.audioFile, part: currentPart, questionText: question.questionText, silenceDuration: 3.5)
                } else {
                    print("TestSimulationManager: ERROR - No Part 3 questions found!")
                    currentPhase = .processing
                    return
                }

            } else {
                print("TestSimulationManager: Test flow completed or invalid part. Finalizing.")
                currentPhase = .processing
            }
        }

    private func playExaminerQuestion(_ audioData: Data, part: Int, questionText: String, silenceDuration: TimeInterval = 2.0, completion: (() -> Void)? = nil) {
        
        // Start playing the audio with a completion handler
        audioPlayerManager.playAudio(from: audioData) { [weak self] in
            guard let self = self else { return }
            print("TestSimulationManager: Examiner audio finished playing. Current Part: \(self.currentPart)")
            
            // Call completion first if provided
            completion?()

            // Only start user response recording if not in Part 2 preparation phase
            if self.currentPart != 2 || (self.currentPart == 2 && self.part2PreparationTimeRemaining <= 0) {
                print("TestSimulationManager: Starting user response recording after audio finished.")
                self.startUserResponseRecording(silenceDuration: silenceDuration, part: part, questionText: questionText)
            }
        }
    }

    // MARK: - Part 2 Specific Logic
    private func startPart2Preparation() {
        print("TestSimulationManager: Part 2: Starting 1-minute preparation time.")
        part2PreparationTimeRemaining = 60
        preparationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.part2PreparationTimeRemaining -= 1
            if self.part2PreparationTimeRemaining <= 0 {
                self.preparationTimer?.invalidate()
                self.preparationTimer = nil
                print("TestSimulationManager: Part 2: Preparation time finished. Playing start speaking prompt.")
                self.playPromptAudioAndStartPart2Speaking()
            }
        }
    }

    private func playPromptAudioAndStartPart2Speaking() {
        print("TestSimulationManager: SIMULATING PROMPT: You can start speaking now.")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            print("TestSimulationManager: Part 2: Starting user speaking recording.")
            self.startUserResponseRecording(silenceDuration: 3.0, part: 2, questionText: self.currentQuestionText, isPart2: true)
            self.startPart2SpeakingTimer()
        }
    }

    private func startPart2SpeakingTimer() {
        part2SpeakingTimeRemaining = 120
        print("TestSimulationManager: Part 2: Starting 2-minute speaking timer.")
        part2SpeakingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.part2SpeakingTimeRemaining -= 1
            if self.part2SpeakingTimeRemaining <= 0 {
                print("TestSimulationManager: Part 2: 2-minute speaking limit reached. Stopping recording.")
                self.part2SpeakingTimer?.invalidate()
                self.part2SpeakingTimer = nil
                self.stopUserResponseAndSave(part: self.currentPart, order: self.currentQuestionIndex, questionText: self.currentQuestionText)
                print("TestSimulationManager: SIMULATING PROMPT: Thank you, that's enough.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.nextQuestionOrPart()
                }
            }
        }
    }

    // MARK: - User Response Handling
    private func startUserResponseRecording(silenceDuration: TimeInterval, part: Int, questionText: String, isPart2: Bool = false) {
        currentQuestionStartTime = Date()
        do {
            try audioRecorderManager.startRecording()
            try speechRecognizerManager.startSpeechRecognition(
                silenceDetectionDuration: silenceDuration,
                onSpeechStart: { [weak self] in
                    self?.isUserSpeaking = true
                    print("TestSimulationManager: User started speaking (via onSpeechStart).")
                },
                onSpeechEnd: { [weak self] transcript in
                    guard let self = self else { return }
                    self.isUserSpeaking = false
                    print("TestSimulationManager: User stopped speaking (via onSpeechEnd). Transcript: '\(transcript.prefix(50))...'")

                    if isPart2 {
                        if self.recordingTime >= 60 && self.recordingTime < 120 {
                            print("TestSimulationManager: Part 2: User stopped speaking after 1 min, before 2 min. Proceeding.")
                            self.stopUserResponseAndSave(
                                part: part,
                                order: currentQuestionIndex,
                                questionText: questionText,
                                transcript: transcript
                            )
                            self.part2SpeakingTimer?.invalidate()
                            self.part2SpeakingTimer = nil
                            self.nextQuestionOrPart()
                        } else if self.recordingTime < 60 {
                            print("TestSimulationManager: Part 2: User stopped speaking before 1 minute. Saving and proceeding.")
                            self.stopUserResponseAndSave(
                                part: part,
                                order: currentQuestionIndex,
                                questionText: questionText,
                                transcript: transcript
                            )
                            self.part2SpeakingTimer?.invalidate()
                            self.part2SpeakingTimer = nil
                            self.nextQuestionOrPart()
                        }
                    } else {
                        print("TestSimulationManager: Part \(part): User stopped speaking. Saving and proceeding.")
                        self.stopUserResponseAndSave(
                            part: part,
                            order: currentQuestionIndex,
                            questionText: questionText,
                            transcript: transcript
                        )
                        self.nextQuestionOrPart()
                    }
                }
            )
        } catch {
            print("TestSimulationManager: Error starting user response flow: \(error.localizedDescription)")
            self.errorMessage = "Recording/Speech Recognition Error: \(error.localizedDescription)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.nextQuestionOrPart()
            }
        }
    }
    
    private func stopUserResponseAndSave(part: Int, order: Int, questionText: String, transcript: String = "") {
        let recordedURL = audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition(shouldCallCompletion: false)

        let answerText = transcript.isEmpty ? "(No speech detected or transcribed)" : transcript

        // Save locally (existing logic)
        DispatchQueue.global(qos: .background).async { [weak self] in
            let newConversation = Conversation(
                part: part,
                order: order,
                question: questionText,
                answer: answerText,
                errors: []
            )
            DispatchQueue.main.async {
                self?.conversations.append(newConversation)
                print("TestSimulationManager: Saved conversation for Part \(part)")
            }
            
            // Upload to backend with comprehensive logging
            print("🔍 Checking upload prerequisites for Part \(part), Order \(order)")
            let audioExists = recordedURL != nil
            let sessionExists = SupabaseService.shared.currentSession?.id != nil
            let questionId = self?.getQuestionId(part: part, order: order)
            let questionIdExists = questionId != nil
            
            print("   Audio URL: \(audioExists ? "✅" : "❌")")
            print("   Session ID: \(sessionExists ? "✅" : "❌")")
            print("   Question ID: \(questionIdExists ? "✅" : "❌") [\(questionId ?? "nil")]")
            
            if let audioURL = recordedURL,
               let sessionId = SupabaseService.shared.currentSession?.id,
               let questionId = questionId {
                
                print("🚀 Starting upload for Part \(part), Question \(order)")
                
                Task {
                    do {
                        try await SupabaseService.shared.uploadResponse(
                            sessionId: sessionId,
                            questionId: questionId,
                            audioURL: audioURL,
                            part: part,
                            order: order
                        )
                        print("✅ Successfully uploaded response for Part \(part), Question \(order)")
                    } catch {
                        print("❌ Upload failed for Part \(part), Question \(order): \(error)")
                        await MainActor.run {
                            self?.errorMessage = "Upload failed: \(error.localizedDescription)"
                        }
                    }
                }
            } else {
                print("❌ Cannot upload Part \(part), Question \(order) - missing prerequisites")
                if !audioExists {
                    print("   Missing: Audio recording")
                }
                if !sessionExists {
                    print("   Missing: Backend session")
                }
                if !questionIdExists {
                    print("   Missing: Question ID mapping")
                }
            }
        }
    }
    
    private func getQuestionId(part: Int, order: Int) -> String? {
        // Try multiple key formats to handle part normalization differences
        let possibleKeys = [
            "\(part)_\(order)",           // Current format
            "\(part-1)_\(order)",         // Normalized format
            "\(part)_\(order+1)",         // Index-based
            "\(part-1)_\(order+1)"        // Normalized index-based
        ]
        
        for key in possibleKeys {
            if let questionId = questionIdMapping[key] {
                print("🔍 Found question ID for part \(part), order \(order) using key '\(key)': \(questionId.prefix(8))...")
                return questionId
            }
        }
        
        print("❌ No question ID found for part \(part), order \(order). Tried keys: \(possibleKeys)")
        print("   Available mappings: \(questionIdMapping.keys.sorted().joined(separator: ", "))")
        return nil
    }
    
    
    private func nextQuestionOrPart() {
        // Clean up all timers and audio operations
        preparationTimer?.invalidate()
        preparationTimer = nil
        part2SpeakingTimer?.invalidate()
        part2SpeakingTimer = nil
        
        // Stop any ongoing audio operations
        audioPlayerManager.stopAudio()
        audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition()
        
        if currentPart == 1 {
            currentQuestionIndex += 1
            if currentQuestionIndex < (questions[0]?.count ?? 0) {
                print("TestSimulationManager: Moving to next question in Part 1. Index: \(currentQuestionIndex)")
                // Add a small delay to ensure clean state transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startConversationFlow()
                }
            } else {
                print("TestSimulationManager: All Part 1 questions covered. Initiating Part 2 transition.")
                currentPart = 2
                currentQuestionIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startConversationFlow()
                }
            }
        } else if currentPart == 2 {
            print("TestSimulationManager: Moving from Part 2 to Part 3.")
            currentPart = 3
            currentQuestionIndex = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startConversationFlow()
            }
        } else if currentPart == 3 {
            currentQuestionIndex += 1
            if currentQuestionIndex < (questions[2]?.count ?? 0) {
                print("TestSimulationManager: Moving to next question in Part 3. Index: \(currentQuestionIndex)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startConversationFlow()
                }
            } else {
                print("TestSimulationManager: All Part 3 questions covered. Initiating test finalization.")
                currentPhase = .processing
            }
        } else {
            print("TestSimulationManager: nextQuestionOrPart called in unexpected state, finalizing test.")
            currentPhase = .processing
        }
    }
    
    func finalizeTest() {
        currentPhase = .processing
        
        Task {
            // Wait a moment for final uploads to complete
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Process with backend
            if let results = await processTestWithBackend() {
                await MainActor.run {
                    self.backendResults = results
                    self.currentPhase = .completed
                    print("TestSimulationManager: Test completed with backend results")
                }
            } else {
                await MainActor.run {
                    // Fallback to local results if backend fails
                    self.currentPhase = .completed
                    print("TestSimulationManager: Test completed with local results only")
                }
            }
        }
    }
}

struct TestSimulatorScreen: View {
    @StateObject private var testManager: TestSimulationManager
    @Environment(\.dismiss) private var dismiss
    @State private var showQuestions = true
    let questions: [Int: [QuestionItem]]
    
    init(questions: [Int: [QuestionItem]]) {
        self.questions = questions
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
                            onStartTest: testManager.startTest
                        )
                    case .testing:
                        ExamTestView(
                            currentPart: testManager.currentPart,
                            currentQuestionText: testManager.currentQuestionText,
                            isExaminerSpeaking: testManager.isExaminerSpeaking,
                            isUserSpeaking: testManager.isUserSpeaking,
                            isRecording: testManager.isRecording,
                            recordingTime: testManager.recordingTime,
                            waveformData: testManager.audioPlayerManager.isPlaying ? generateVisualWaveformData(for: testManager.audioPlayerManager.currentPlaybackTime, duration: testManager.audioPlayerManager.currentAudioDuration, isSpeaking: testManager.isExaminerSpeaking) : Array(repeating: 0.0, count: 50),
                            userWaveformData: testManager.audioRecorderManager.isRecording ? generateUserVisualWaveformData(power: testManager.audioRecorderManager.averagePower) : Array(repeating: 0.0, count: 30))
                        case .completed:
                            if let backendResults = testManager.backendResults {
                                BackendResultsView(
                                    testResults: backendResults,
                                    localConversations: testManager.conversations
                                )
                            } else {
                                TestCompletedView(onViewResults: {
                                    dismiss()
                                    // Show local results or error message
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
                                        }
                                    }
                                )
                                .onAppear {
                                    // Your existing processing logic, but now handled by testManager.finalizeTest()
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

struct WaveformView: View {
    let amplitudes: [Double]
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(amplitudes.indices, id: \.self) { index in
                Rectangle()
                    .frame(width: 4, height: max(1, amplitudes[index] * 50)) // Scale height
                    .cornerRadius(2)
                    .foregroundColor(color)
            }
        }
    }
}









// MARK: - Preview
struct TestSimulatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Create dummy audio data for preview purposes
        let dummyAudioData = "dummy audio data for testing".data(using: .utf8)!

        let mockTestQuestions: [Int: [QuestionItem]] = [
            0: [ // Part 1
                QuestionItem(
                    id: UUID().uuidString,
                    part: 1,
                    order: 1,
                    questionText: "Let's talk about your hometown. Where are you from?",
                    audioFile: dummyAudioData
                ),
                QuestionItem(
                    id: UUID().uuidString,
                    part: 1,
                    order: 2,
                    questionText: "What do you like most about your hometown?",
                    audioFile: dummyAudioData
                ),
                QuestionItem(
                    id: UUID().uuidString,
                    part: 1,
                    order: 3,
                    questionText: "Is there anything you would like to change about it?",
                    audioFile: dummyAudioData
                )
            ],
            1: [ // Part 2 (Cue Card)
                QuestionItem(
                    id: UUID().uuidString,
                    part: 2,
                    order: 1,
                    questionText: """
                    Describe a time you helped someone.
                    You should say:
                    - who you helped
                    - what the situation was
                    - how you helped them
                    and explain how you felt after helping this person.
                    """,
                    audioFile: dummyAudioData
                )
            ],
            2: [ // Part 3
                QuestionItem(
                    id: UUID().uuidString,
                    part: 3,
                    order: 1,
                    questionText: "Let's discuss helping others in general. Why do people choose to help others?",
                    audioFile: dummyAudioData
                ),
                QuestionItem(
                    id: UUID().uuidString,
                    part: 3,
                    order: 2,
                    questionText: "Do you think people today are more or less willing to help others compared to the past?",
                    audioFile: dummyAudioData
                ),
                QuestionItem(
                    id: UUID().uuidString,
                    part: 3,
                    order: 3,
                    questionText: "What are some of the benefits of volunteering in the community?",
                    audioFile: dummyAudioData
                )
            ]
        ]

        TestSimulatorScreen(questions: mockTestQuestions)
            .environment(\.colorScheme, .light)
    }
}



// MARK: - Enhanced TestSimulationManager with Backend Integration

extension TestSimulationManager {
    
    // MARK: - Backend Integration Methods
    
    /// Initialize test session with backend
    func initializeBackendSession() async {
        do {
            let session = try await SupabaseService.shared.createTestSession()
            print("✅ Backend session created: \(session.id)")
        } catch {
            print("❌ Failed to create backend session: \(error)")
            self.errorMessage = "Failed to initialize test session: \(error.localizedDescription)"
        }
    }
    
    /// Enhanced method to save response with backend upload
    private func stopUserResponseAndSaveWithBackend(
        part: Int,
        order: Int,
        questionId: String,
        questionText: String,
        transcript: String = ""
    ) {
        let recordedURL = audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition(shouldCallCompletion: false)

        let answerText = transcript.isEmpty ? "(No speech detected or transcribed)" : transcript

        // Save locally first (existing logic)
        DispatchQueue.global(qos: .background).async { [weak self] in
            let newConversation = Conversation(
                part: part,
                order: order,
                question: questionText,
                answer: answerText,
                errors: []
            )
            
            DispatchQueue.main.async {
                self?.conversations.append(newConversation)
                print("TestSimulationManager: Saved conversation locally for Part \(part)")
            }
            
            // Upload to backend if we have audio and session
            if let audioURL = recordedURL,
               let sessionId = SupabaseService.shared.currentSession?.id {
                
                Task {
                    do {
                        try await SupabaseService.shared.uploadResponse(
                            sessionId: sessionId,
                            questionId: questionId,
                            audioURL: audioURL,
                            part: part,
                            order: order
                        )
                        print("✅ Uploaded response for Part \(part), Question \(order)")
                    } catch {
                        print("❌ Failed to upload response: \(error)")
                        DispatchQueue.main.async {
                            self?.errorMessage = "Upload failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
    
    /// Process test completion with backend
//    func processTestWithBackend() async -> TestResults? {
//        guard let sessionId = SupabaseService.shared.currentSession?.id else {
//            print("❌ No active session for processing")
//            return nil
//        }
//        
//        do {
//            // Wait for backend processing to complete
//            SupabaseService.shared.isProcessing = true
//            let results = try await SupabaseService.shared.waitForResults(sessionId: sessionId)
//            SupabaseService.shared.isProcessing = false
//            
//            print("✅ Got results from backend:")
//            print("   Overall Band Score: \(results.overallBandScore)")
//            print("   Fluency: \(results.fluencyScore)")
//            print("   Pronunciation: \(results.pronunciationScore)")
//            
//            return results
//            
//        } catch {
//            print("❌ Failed to get results: \(error)")
//            SupabaseService.shared.isProcessing = false
//            self.errorMessage = "Failed to process results: \(error.localizedDescription)"
//            return nil
//        }
//    }
    
    func processTestWithBackend() async -> TestResults? {
            guard let sessionId = SupabaseService.shared.currentSession?.id else {
                print("❌ No active session for processing")
                return nil
            }
            
            do {
                await MainActor.run {
                    SupabaseService.shared.isProcessing = true
                }
                
                let results = try await SupabaseService.shared.waitForResults(sessionId: sessionId)
                
                await MainActor.run {
                    SupabaseService.shared.isProcessing = false
                }
                
                print("✅ Got results from backend:")
                print("   Overall Band Score: \(results.overallBandScore)")
                print("   Fluency: \(results.fluencyScore)")
                print("   Pronunciation: \(results.pronunciationScore)")
                
                return results
                
            } catch {
                print("❌ Failed to get results: \(error)")
                await MainActor.run {
                    SupabaseService.shared.isProcessing = false
                    self.errorMessage = "Failed to process results: \(error.localizedDescription)"
                }
                return nil
            }
        }
}

// MARK: - Updated Test Start Method

extension TestSimulationManager {
    
    /// Enhanced start test with backend initialization
    func startTestWithBackend() {
        print("TestSimulationManager: startTestWithBackend() called")
        
        currentPhase = .testing
        
        // First initialize backend session
        Task {
            await initializeBackendSession()
            
            // Then request permissions and start
            await MainActor.run {
                requestAudioAndSpeechPermissions { [weak self] success in
                    if success {
                        print("TestSimulationManager: Permissions granted. Starting conversation flow.")
                        self?.startConversationFlow()
                    } else {
                        self?.errorMessage = "Microphone and Speech Recognition permissions are required to start the test. Please enable them in Settings."
                        self?.currentPhase = .preparation
                        print("TestSimulationManager: Permissions denied. Test cannot start.")
                    }
                }
            }
        }
    }
}



// Add this extension to your existing TestSimulationManager.swift file

extension TestSimulationManager {
    
    // MARK: - Enhanced Initialization with Question ID Mapping
    
    convenience init(questionsWithBackend questions: [Int: [QuestionItem]]) {
        self.init(questions: questions)
        buildQuestionIdMapping()
    }
    
    private func buildQuestionIdMapping() {
        questionIdMapping.removeAll()
        
        for (normalizedPart, items) in questions {
            // Convert normalized part (0,1,2) back to database part (1,2,3)
            let databasePart = normalizedPart + 1
            
            for (index, item) in items.enumerated() {
                // Try multiple key formats to ensure mapping works
                let keys = [
                    "\(databasePart)_\(item.order)",  // Database format: "1_1", "1_2", etc.
                    "\(normalizedPart)_\(item.order)", // Normalized format: "0_1", "0_2", etc.
                    "\(databasePart)_\(index + 1)",   // Index-based: "1_1", "1_2", etc.
                    "\(normalizedPart)_\(index + 1)"  // Normalized index: "0_1", "0_2", etc.
                ]
                
                // Map all possible key formats to the same question ID
                for key in keys {
                    questionIdMapping[key] = item.id
                    print("🗂️ Mapped \(key) -> \(item.id)")
                }
            }
        }
        
        print("✅ Question ID mapping completed: \(questionIdMapping.count) mappings")
        
        // Debug: Print unique mappings only
        let uniqueQuestionIds = Set(questionIdMapping.values)
        print("📊 Mapped \(uniqueQuestionIds.count) unique questions with \(questionIdMapping.count) total key mappings")
        
        // Show a sample of mappings
        let sampleMappings = questionIdMapping.sorted(by: { $0.key < $1.key }).prefix(10)
        for (key, questionId) in sampleMappings {
            print("   \(key) -> \(questionId.prefix(8))...")
        }
    }
    
    // MARK: - Enhanced Response Saving with Proper Question IDs
    
    private func stopUserResponseAndSaveWithBackend(
        part: Int,
        order: Int,
        questionText: String,
        transcript: String = ""
    ) {
        let recordedURL = audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition(shouldCallCompletion: false)

        let answerText = transcript.isEmpty ? "(No speech detected or transcribed)" : transcript

        // Save locally first (existing logic)
        DispatchQueue.global(qos: .background).async { [weak self] in
            let newConversation = Conversation(
                part: part,
                order: order,
                question: questionText,
                answer: answerText,
                errors: []
            )
            
            DispatchQueue.main.async {
                self?.conversations.append(newConversation)
                print("TestSimulationManager: Saved conversation locally for Part \(part)")
            }
            
            // Upload to backend if we have audio and session
            print("🔍 Checking upload prerequisites for Part \(part), Order \(order)")
            let audioExists = recordedURL != nil
            let sessionExists = SupabaseService.shared.currentSession?.id != nil
            let questionId = self?.getQuestionId(part: part, order: order)
            let questionIdExists = questionId != nil
            
            print("   Audio URL: \(audioExists ? "✅" : "❌")")
            print("   Session ID: \(sessionExists ? "✅" : "❌")")
            print("   Question ID: \(questionIdExists ? "✅" : "❌") [\(questionId ?? "nil")]")
            
            if let audioURL = recordedURL,
               let sessionId = SupabaseService.shared.currentSession?.id,
               let questionId = questionId {
                
                print("🚀 Starting upload for Part \(part), Question \(order)")
                
                Task {
                    do {
                        try await SupabaseService.shared.uploadResponse(
                            sessionId: sessionId,
                            questionId: questionId,
                            audioURL: audioURL,
                            part: part,
                            order: order
                        )
                        print("✅ Successfully uploaded response for Part \(part), Question \(order)")
                    } catch {
                        print("❌ Upload failed for Part \(part), Question \(order): \(error)")
                        await MainActor.run {
                            self?.errorMessage = "Upload failed: \(error.localizedDescription)"
                        }
                    }
                }
            } else {
                print("❌ Cannot upload Part \(part), Question \(order) - missing prerequisites")
            }
        }
    }
    
}
