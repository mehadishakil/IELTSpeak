import Foundation
import AVFoundation
import Combine
import SwiftUI
import Speech

private enum TestConstants {
    static let part2PreparationTime: TimeInterval = 60
    static let part2SpeakingTime: TimeInterval = 120
    static let defaultSilenceDuration: TimeInterval = 2.0
    static let part3SilenceDuration: TimeInterval = 3.5
    static let part2SilenceDuration: TimeInterval = 3.0
    static let stateTransitionDelay: TimeInterval = 0.5
    static let finalUploadDelay: TimeInterval = 2.0
    static let promptDelay: TimeInterval = 1.5
    static let nextQuestionDelay: TimeInterval = 1.0
}

class TestSimulationManager: ObservableObject {
    @Published var currentPhase: TestPhase = .preparation
    @Published var currentPart: Int = 1
    @Published var currentQuestionIndex: Int = 0
    @Published var isExaminerSpeaking: Bool = false
    @Published var isUserSpeaking: Bool = false
    @Published var isRecording: Bool = false
    @Published var recordingTime: TimeInterval = 0
    @Published var part2PreparationTimeRemaining: TimeInterval = TestConstants.part2PreparationTime
    @Published var part2SpeakingTimeRemaining: TimeInterval = TestConstants.part2SpeakingTime
    @Published var currentQuestionText: String = ""
    @Published var errorMessage: String?
    @Published var backendResults: TestResults?
    @Published var isUploadingResponses = false
    private var questionIds: [String] = [] // Store question IDs from backend
    private var questionIdMapping: [String: String] = [:]

    // MARK: - Audio Managers
    let audioPlayerManager = AudioPlayerManager()
    let audioRecorderManager = AudioRecorderManager()
    let speechRecognizerManager = SpeechRecognizerManager()

    // MARK: - Test Data
    var conversations: [Conversation] = []
    private let questions: [Int: [QuestionItem]]
    
    // MARK: - State Management
    private var currentRecordedAudioURL: URL?
    private var currentQuestionStartTime: Date?
    private var preparationTimer: Timer?
    private var part2SpeakingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(questions: [Int: [QuestionItem]]) {
        self.questions = questions
        
        logQuestionsStructure()
        setupBindings()
        buildQuestionIdMapping()
    }

    private func setupBindings() {
        Publishers.CombineLatest4(
            audioPlayerManager.$isPlaying,
            audioRecorderManager.$isRecording,
            audioRecorderManager.$recordingTime,
            speechRecognizerManager.$isSpeechDetected
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isPlaying, isRecording, recordingTime, isSpeechDetected in
            self?.isExaminerSpeaking = isPlaying
            self?.isRecording = isRecording
            self?.recordingTime = recordingTime
            self?.isUserSpeaking = isSpeechDetected
        }
        .store(in: &cancellables)
        
        speechRecognizerManager.$error
            .compactMap { $0 as? Error }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.handleSpeechRecognitionError(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Starts the IELTS speaking test with backend initialization and permission requests
    func startTest() {
        print("TestSimulationManager: startTest() called")
        print("Current questions keys: \(Array(questions.keys).sorted())")
        
        currentPhase = .testing
        
        Task {
            await initializeBackendSession()
            await requestPermissionsAndStart()
        }
    }
    
    @MainActor
    private func requestPermissionsAndStart() async {
        let permissionsGranted = await requestAudioAndSpeechPermissions()
        if permissionsGranted {
            print("TestSimulationManager: Permissions granted. Starting conversation flow.")
            startConversationFlow()
        } else {
            errorMessage = "Microphone and Speech Recognition permissions are required."
            currentPhase = .preparation
        }
    }
    
    private func requestAudioAndSpeechPermissions() async -> Bool {
        let microphoneGranted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        let speechGranted = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        return microphoneGranted && speechGranted == .authorized
    }

    func startConversationFlow() {
        logConversationFlowStart()
        
        guard currentPhase == .testing else {
            print("TestSimulationManager: Not in testing phase, returning")
            return
        }

        cleanupPreviousStates()
        
        switch currentPart {
        case 1:
            handlePart1Flow()
        case 2:
            handlePart2Flow()
        case 3:
            handlePart3Flow()
        default:
            print("TestSimulationManager: Test flow completed or invalid part. Finalizing.")
            currentPhase = .processing
        }
    }
    
    private func logConversationFlowStart() {
        print("TestSimulationManager: startConversationFlow() called")
        print("Current phase: \(currentPhase), part: \(currentPart), questionIndex: \(currentQuestionIndex)")
        print("Available question parts: \(Array(questions.keys).sorted())")
    }
    
    private func cleanupPreviousStates() {
        _ = audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition()
        audioPlayerManager.stopAudio()
        part2SpeakingTimer?.invalidate()
        preparationTimer?.invalidate()
        print("TestSimulationManager: Cleaned up previous states.")
    }
    
    private func handlePart1Flow() {
        print("Starting Part 1 - Questions available:")
        guard let part1Questions = questions[0] else {
            handleMissingQuestions(part: 1)
            return
        }
        
        logPartQuestions(part: 1, questions: part1Questions)
        
        guard currentQuestionIndex < part1Questions.count else {
            print("TestSimulationManager: Part 1 finished. Moving to Part 2.")
            moveToNextPart()
            return
        }
        
        let question = part1Questions[currentQuestionIndex]
        currentQuestionText = question.questionText
        print("TestSimulationManager: Part 1, Question \(currentQuestionIndex + 1): Playing examiner audio for '\(currentQuestionText)'")
        playExaminerQuestion(question.audioFile, part: currentPart, questionText: question.questionText, silenceDuration: TestConstants.defaultSilenceDuration)
    }
    
    private func handlePart2Flow() {
        print("Starting Part 2 - Questions available:")
        guard let part2Questions = questions[1], !part2Questions.isEmpty else {
            print("TestSimulationManager: Part 2 finished or no questions. Moving to Part 3.")
            moveToNextPart()
            return
        }
        
        let cueCard = part2Questions[currentQuestionIndex]
        currentQuestionText = cueCard.questionText
        print("TestSimulationManager: Part 2: Playing cue card audio for '\(currentQuestionText.prefix(30))...'")
        playExaminerQuestion(cueCard.audioFile, part: currentPart, questionText: cueCard.questionText) { [weak self] in
            self?.startPart2Preparation()
        }
    }
    
    private func handlePart3Flow() {
        print("Starting Part 3 - Questions available:")
        guard let part3Questions = questions[2] else {
            handleMissingQuestions(part: 3)
            return
        }
        
        logPartQuestions(part: 3, questions: part3Questions)
        
        guard currentQuestionIndex < part3Questions.count else {
            print("TestSimulationManager: Part 3 finished. Moving to Processing.")
            currentPhase = .processing
            return
        }
        
        let question = part3Questions[currentQuestionIndex]
        currentQuestionText = question.questionText
        print("TestSimulationManager: Part 3, Question \(currentQuestionIndex + 1): Playing examiner audio for '\(currentQuestionText.prefix(30))...'")
        playExaminerQuestion(question.audioFile, part: currentPart, questionText: question.questionText, silenceDuration: TestConstants.part3SilenceDuration)
    }
    
    private func handleMissingQuestions(part: Int) {
        print("TestSimulationManager: ERROR - No Part \(part) questions found!")
        if part < 3 {
            moveToNextPart()
        } else {
            errorMessage = "No Part \(part) questions available"
            currentPhase = .processing
        }
    }
    
    private func logPartQuestions(part: Int, questions: [QuestionItem]) {
        print("Part \(part) has \(questions.count) questions")
        for (index, question) in questions.enumerated() {
            print("  Q\(index + 1): \(question.questionText.prefix(30))...")
        }
    }
    
    private func moveToNextPart() {
        currentPart += 1
        currentQuestionIndex = 0
        startConversationFlow()
    }

    private func playExaminerQuestion(
        _ audioData: Data, 
        part: Int, 
        questionText: String, 
        silenceDuration: TimeInterval = TestConstants.defaultSilenceDuration, 
        completion: (() -> Void)? = nil
    ) {
        audioPlayerManager.playAudio(from: audioData) { [weak self] in
            self?.handleAudioPlaybackCompletion(part: part, questionText: questionText, silenceDuration: silenceDuration, completion: completion)
        }
    }
    
    private func handleAudioPlaybackCompletion(
        part: Int, 
        questionText: String, 
        silenceDuration: TimeInterval, 
        completion: (() -> Void)?
    ) {
        print("TestSimulationManager: Examiner audio finished playing. Current Part: \(currentPart)")
        
        completion?()

        if shouldStartUserResponseRecording() {
            print("TestSimulationManager: Starting user response recording after audio finished.")
            startUserResponseRecording(silenceDuration: silenceDuration, part: part, questionText: questionText)
        }
    }
    
    private func shouldStartUserResponseRecording() -> Bool {
        return currentPart != 2 || (currentPart == 2 && part2PreparationTimeRemaining <= 0)
    }
    
    // MARK: - Helper Methods
    private func logQuestionsStructure() {
        print("TestSimulationManager Init - Questions structure:")
        for (part, items) in questions {
            print("Part \(part): \(items.count) questions")
            for (index, item) in items.enumerated() {
                print("  Q\(index + 1): \(item.questionText.prefix(50))... (ID: \(item.id))")
            }
        }
    }
    
    private func handleSpeechRecognitionError(_ error: Error) {
        errorMessage = "Speech Recognition Error: \(error)"
        print("TestSimulationManager: Speech Recognition Error: \(error)")
    }
    
    private func handleRecordingError(_ error: Error) {
        print("TestSimulationManager: Error starting user response flow: \(error.localizedDescription)")
        errorMessage = "Recording/Speech Recognition Error: \(error.localizedDescription)"
        DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.defaultSilenceDuration) {
            self.nextQuestionOrPart()
        }
    }
    
    private func handlePart2SpeechEnd(part: Int, questionText: String, transcript: String) {
        if recordingTime >= 60 && recordingTime < 120 {
            print("TestSimulationManager: Part 2: User stopped speaking after 1 min, before 2 min. Proceeding.")
        } else if recordingTime < 60 {
            print("TestSimulationManager: Part 2: User stopped speaking before 1 minute. Saving and proceeding.")
        }
        
        stopUserResponseAndSave(
            part: part,
            order: currentQuestionIndex,
            questionText: questionText,
            transcript: transcript
        )
        part2SpeakingTimer?.invalidate()
        part2SpeakingTimer = nil
        nextQuestionOrPart()
    }

    // MARK: - Part 2 Specific Logic
    private func startPart2Preparation() {
        print("TestSimulationManager: Part 2: Starting 1-minute preparation time.")
        part2PreparationTimeRemaining = TestConstants.part2PreparationTime
        preparationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePreparationTimer()
        }
    }
    
    private func updatePreparationTimer() {
        part2PreparationTimeRemaining -= 1
        if part2PreparationTimeRemaining <= 0 {
            preparationTimer?.invalidate()
            preparationTimer = nil
            print("TestSimulationManager: Part 2: Preparation time finished. Playing start speaking prompt.")
            playPromptAudioAndStartPart2Speaking()
        }
    }

    private func playPromptAudioAndStartPart2Speaking() {
        print("TestSimulationManager: SIMULATING PROMPT: You can start speaking now.")
        DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.promptDelay) { [weak self] in
            self?.beginPart2Speaking()
        }
    }
    
    private func beginPart2Speaking() {
        print("TestSimulationManager: Part 2: Starting user speaking recording.")
        startUserResponseRecording(
            silenceDuration: TestConstants.part2SilenceDuration, 
            part: 2, 
            questionText: currentQuestionText, 
            isPart2: true
        )
        startPart2SpeakingTimer()
    }

    private func startPart2SpeakingTimer() {
        part2SpeakingTimeRemaining = TestConstants.part2SpeakingTime
        print("TestSimulationManager: Part 2: Starting 2-minute speaking timer.")
        part2SpeakingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePart2SpeakingTimer()
        }
    }
    
    private func updatePart2SpeakingTimer() {
        part2SpeakingTimeRemaining -= 1
        if part2SpeakingTimeRemaining <= 0 {
            handlePart2TimeLimit()
        }
    }
    
    private func handlePart2TimeLimit() {
        print("TestSimulationManager: Part 2: 2-minute speaking limit reached. Stopping recording.")
        part2SpeakingTimer?.invalidate()
        part2SpeakingTimer = nil
        stopUserResponseAndSave(part: currentPart, order: currentQuestionIndex, questionText: currentQuestionText)
        print("TestSimulationManager: SIMULATING PROMPT: Thank you, that's enough.")
        DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.nextQuestionDelay) {
            self.nextQuestionOrPart()
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
                        self.handlePart2SpeechEnd(part: part, questionText: questionText, transcript: transcript)
                    } else {
                        print("TestSimulationManager: Part \(part): User stopped speaking. Saving and proceeding.")
                        self.stopUserResponseAndSave(
                            part: part,
                            order: self.currentQuestionIndex,
                            questionText: questionText,
                            transcript: transcript
                        )
                        self.nextQuestionOrPart()
                    }
                }
            )
        } catch {
            handleRecordingError(error)
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
        let possibleKeys = generatePossibleKeys(part: part, order: order)
        
        for key in possibleKeys {
            if let questionId = questionIdMapping[key] {
                print("🔍 Found question ID for part \(part), order \(order) using key '\(key)': \(questionId.prefix(8))...")
                return questionId
            }
        }
        
        logQuestionIdNotFound(part: part, order: order, keys: possibleKeys)
        return nil
    }
    
    private func generatePossibleKeys(part: Int, order: Int) -> [String] {
        return [
            "\(part)_\(order)",           // Current format
            "\(part-1)_\(order)",         // Normalized format
            "\(part)_\(order+1)",         // Index-based
            "\(part-1)_\(order+1)"        // Normalized index-based
        ]
    }
    
    private func logQuestionIdNotFound(part: Int, order: Int, keys: [String]) {
        print("❌ No question ID found for part \(part), order \(order). Tried keys: \(keys)")
        print("   Available mappings: \(questionIdMapping.keys.sorted().joined(separator: ", "))")
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
                DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.stateTransitionDelay) {
                    self.startConversationFlow()
                }
            } else {
                print("TestSimulationManager: All Part 1 questions covered. Initiating Part 2 transition.")
                currentPart = 2
                currentQuestionIndex = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.stateTransitionDelay) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.stateTransitionDelay) {
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
            try? await Task.sleep(nanoseconds: UInt64(TestConstants.finalUploadDelay * 1_000_000_000))
            
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
    
    // MARK: - Waveform Generation
    
    /// Generates visual waveform data for examiner audio playback
    func generateVisualWaveformData(for currentTime: TimeInterval, duration: TimeInterval, isSpeaking: Bool) -> [Double] {
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

    /// Generates visual waveform data for user speech recording based on microphone power
    func generateUserVisualWaveformData(power: Float) -> [Double] {
        var data = Array(repeating: 0.0, count: 30)
        
        // Power is already converted to linear scale (0.0 to 1.0) in AudioRecorderManager
        // Amplify for better visualization and add some variance
        let normalizedPower = Double(min(1.0, power * 5.0)) // Amplify for better visualization
        
        // Create varied waveform bars with random heights based on power level
        for i in 0..<30 {
            if normalizedPower > 0.01 { // Only show bars if there's actual sound
                let variation = Double.random(in: 0.3...1.0)
                data[i] = normalizedPower * variation
            } else {
                data[i] = 0.0 // Silent
            }
        }
        return data
    }
}

extension TestSimulationManager {
    
    func initializeBackendSession() async {
        do {
            let session = try await SupabaseService.shared.createTestSession()
            print("✅ Backend session created: \(session.id)")
        } catch {
            print("❌ Failed to create backend session: \(error)")
            await MainActor.run {
                self.errorMessage = "Failed to initialize test session: \(error.localizedDescription)"
            }
        }
    }
    
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
                return await handleProcessingError(error)
            }
        }
    
    private func handleProcessingError(_ error: Error) async -> TestResults? {
        print("❌ Failed to get results: \(error)")
        await MainActor.run {
            SupabaseService.shared.isProcessing = false
            self.errorMessage = "Failed to process results: \(error.localizedDescription)"
        }
        return nil
        }
}

extension TestSimulationManager {
    
    /// Enhanced start test with backend initialization
    func startTestWithBackend() {
        print("TestSimulationManager: startTestWithBackend() called")
        
        currentPhase = .testing
        
        // First initialize backend session
        Task {
            await initializeBackendSession()
            
            // Then request permissions and start
            await requestPermissionsAndStart()
        }
    }
}

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
                    // Mapping logged in batch below
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

#Preview {
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
