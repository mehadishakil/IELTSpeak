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
    static let finalUploadDelay: TimeInterval = 4.0
    static let promptDelay: TimeInterval = 1.5
    static let nextQuestionDelay: TimeInterval = 1.0
}

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    
    init(isValid: Bool, errors: [String] = [], warnings: [String] = []) {
        self.isValid = isValid
        self.errors = errors
        self.warnings = warnings
    }
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
    private var uploadedQuestions = Set<String>() // store questionId strings
    private var activeUploadTasks = Set<Task<Void, Never>>() // Keep strong references to upload tasks


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
            print("TestSimulationManager: Permissions granted. Running pre-test validation...")
            
            // Run comprehensive validation before starting test
            let validationResults = await runPreTestValidation()
            
            if validationResults.isValid {
                print("✅ Pre-test validation passed. Starting conversation flow.")
                startConversationFlow()
            } else {
                print("❌ Pre-test validation failed: \(validationResults.errors.joined(separator: ", "))")
                errorMessage = "Test validation failed: \(validationResults.errors.first ?? "Unknown error")"
                currentPhase = .preparation
            }
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
    
    // MARK: - Pre-Test Validation
    
    /// Comprehensive validation before starting test to ensure all uploads will succeed
    private func runPreTestValidation() async -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        print("🔍 Running comprehensive pre-test validation...")
        
        // 1. Validate question structure
        let questionValidation = validateQuestionStructure()
        errors.append(contentsOf: questionValidation.errors)
        warnings.append(contentsOf: questionValidation.warnings)
        
        // 2. Validate question ID mappings
        let mappingValidation = validateQuestionIdMappings()
        errors.append(contentsOf: mappingValidation.errors)
        warnings.append(contentsOf: mappingValidation.warnings)
        
        // 3. Validate backend connectivity
        let backendValidation = await validateBackendConnectivity()
        errors.append(contentsOf: backendValidation.errors)
        warnings.append(contentsOf: backendValidation.warnings)
        
        // 4. Validate audio subsystem
        let audioValidation = validateAudioSubsystem()
        errors.append(contentsOf: audioValidation.errors)
        warnings.append(contentsOf: audioValidation.warnings)
        
        let isValid = errors.isEmpty
        
        print("📊 Validation Results:")
        print("   Valid: \(isValid ? "✅" : "❌")")
        print("   Errors: \(errors.count)")
        print("   Warnings: \(warnings.count)")
        
        if !errors.isEmpty {
            print("   🚨 Critical Issues:")
            for (index, error) in errors.enumerated() {
                print("     \(index + 1). \(error)")
            }
        }
        
        if !warnings.isEmpty {
            print("   ⚠️ Warnings:")
            for (index, warning) in warnings.enumerated() {
                print("     \(index + 1). \(warning)")
            }
        }
        
        return ValidationResult(isValid: isValid, errors: errors, warnings: warnings)
    }
    
    private func validateQuestionStructure() -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Check if we have questions for all expected parts
        let expectedParts = [0, 1, 2] // Frontend uses 0-based indexing
        for part in expectedParts {
            guard let partQuestions = questions[part], !partQuestions.isEmpty else {
                errors.append("Missing questions for Part \(part + 1)")
                continue
            }
            
            // Validate individual questions
            for (index, question) in partQuestions.enumerated() {
                if question.id.isEmpty {
                    errors.append("Question \(index + 1) in Part \(part + 1) has empty ID")
                }
                
                if question.questionText.isEmpty {
                    warnings.append("Question \(index + 1) in Part \(part + 1) has empty text")
                }
                
                if question.audioFile.isEmpty {
                    errors.append("Question \(index + 1) in Part \(part + 1) has no audio data")
                }
            }
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    private func validateQuestionIdMappings() -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Simple validation: ensure all questions have valid IDs
        for (partKey, partQuestions) in questions {
            for (index, question) in partQuestions.enumerated() {
                if question.id.isEmpty {
                    errors.append("Question \(index + 1) in Part \(partKey + 1) has empty ID")
                }
            }
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    private func validateBackendConnectivity() async -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Check if we have an active session
        if SupabaseService.shared.currentSession == nil {
            errors.append("No active backend session")
        }
        
        // Validate network connectivity by attempting a lightweight operation
        do {
            let sessionId = SupabaseService.shared.currentSession?.id ?? "test"
            _ = try await SupabaseService.shared.checkSessionStatus(sessionId: sessionId)
        } catch {
            warnings.append("Backend connectivity check failed: \(error.localizedDescription)")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
    }
    
    private func validateAudioSubsystem() -> ValidationResult {
        var errors: [String] = []
        var warnings: [String] = []
        
        // Check audio session availability
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if !audioSession.isInputAvailable {
                errors.append("Audio input not available")
            }
        } catch {
            errors.append("Audio session validation failed: \(error.localizedDescription)")
        }
        
        // Check speech recognition availability
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            errors.append("Speech recognition not authorized")
            return ValidationResult(isValid: false, errors: errors, warnings: warnings)
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors, warnings: warnings)
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
            order: currentQuestionIndex + 1,  // Convert to 1-based indexing
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
        stopUserResponseAndSave(part: currentPart, order: currentQuestionIndex + 1, questionText: currentQuestionText)  // Convert to 1-based indexing
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
                            order: self.currentQuestionIndex + 1,  // Convert to 1-based indexing
                            questionText: questionText,
                            transcript: transcript
                        )
                        print("🔄 CALLING nextQuestionOrPart() after saving Part \(part), Order \(self.currentQuestionIndex + 1)")
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
        
        // 🔍 CRITICAL DEBUG: Track this specific call
        print("🎯 STOP_USER_RESPONSE_AND_SAVE CALLED:")
        print("   Part: \(part), Order: \(order)")
        print("   Question: \(questionText.prefix(50))...")
        print("   Current state - Part: \(currentPart), QuestionIndex: \(currentQuestionIndex)")
        print("   Audio URL: \(recordedURL?.path ?? "nil")")
        print("   Thread: \(Thread.isMainThread ? "Main" : "Background")")

        // Save locally (existing logic)
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { 
                print("❌ Self is nil in stopUserResponseAndSave background task")
                return 
            }
            
            print("🔄 Background task started for Part \(part), Order \(order)")
            
            let newConversation = Conversation(
                part: part,
                order: order,
                question: questionText,
                answer: answerText,
                errors: []
            )
            DispatchQueue.main.async {
                self.conversations.append(newConversation)
                print("✅ Saved conversation locally for Part \(part), Order \(order)")
            }
            
            // Upload to backend with comprehensive logging
            print("🔍 DETAILED UPLOAD CHECK for Part \(part), Order \(order):")
            let audioExists = recordedURL != nil
            let sessionExists = SupabaseService.shared.currentSession?.id != nil
            let sessionId = SupabaseService.shared.currentSession?.id
            let questionId = self.getQuestionId(part: part, order: order)
            let questionIdExists = questionId != nil
            
            print("   📱 Current App State:")
            print("     - Current Part: \(self.currentPart)")
            print("     - Current Question Index: \(self.currentQuestionIndex)")
            print("     - Current Phase: \(self.currentPhase)")
            print("   📋 Upload Prerequisites:")
            print("     - Audio URL: \(audioExists ? "✅" : "❌") [\(recordedURL?.path ?? "nil")]")
            print("     - Session ID: \(sessionExists ? "✅" : "❌") [\(sessionId ?? "nil")]")
            print("     - Question ID: \(questionIdExists ? "✅" : "❌") [\(questionId ?? "nil")]")
            print("   🎯 Target Upload:")
            print("     - Upload Part: \(part)")
            print("     - Upload Order: \(order)")
            print("     - Question Text: \(questionText.prefix(30))...")
            
            if let audioURL = recordedURL,
               let sessionId = SupabaseService.shared.currentSession?.id,
               let questionId = questionId {
                
                // ✅ Duplicate prevention
                if self.uploadedQuestions.contains(questionId) {
                    print("⏩ DUPLICATE UPLOAD PREVENTION: Skipping questionId: \(questionId)")
                    print("   Already uploaded questions: \(self.uploadedQuestions)")
                    return
                }
                
                print("🚀 INITIATING UPLOAD for Part \(part), Question \(order)")
                print("   Question ID: \(questionId)")
                print("   Session ID: \(sessionId)")
                print("   Audio Path: \(audioURL.path)")
                print("   File Size: \(try? FileManager.default.attributesOfItem(atPath: audioURL.path)[.size] ?? "unknown") bytes")
                print("   Uploaded Questions Before: \(self.uploadedQuestions)")
                
                self.uploadedQuestions.insert(questionId)
                
                // 🔒 CRITICAL FIX: Create strong reference to upload task to prevent cancellation
                let uploadTaskId = "upload_\(part)_\(order)_\(Date().timeIntervalSince1970)"
                print("🔒 Creating upload task with ID: \(uploadTaskId)")
                
                let uploadTask = Task {
                    print("📤 UPLOAD TASK STARTED: \(uploadTaskId)")
                    print("   Current thread: \(Thread.current)")
                    
                    do {
                        print("📡 Calling SupabaseService.uploadResponse...")
                        try await SupabaseService.shared.uploadResponse(
                            sessionId: sessionId,
                            questionId: questionId,
                            audioURL: audioURL,
                            part: part,
                            order: order
                        )
                        print("✅ UPLOAD SUCCESS: Part \(part), Question \(order) [Task: \(uploadTaskId)]")
                        
                        // Mark as successfully uploaded
                        await MainActor.run {
                            if let currentError = self.errorMessage, currentError.contains("Upload failed") {
                                self.errorMessage = nil // Clear upload errors on success
                            }
                        }
                        
                    } catch {
                        print("❌ UPLOAD FAILED: Part \(part), Question \(order) [Task: \(uploadTaskId)]")
                        print("   Error: \(error)")
                        print("   Error type: \(type(of: error))")
                        
                        await MainActor.run {
                            // Remove from uploaded set to allow retry
                            self.uploadedQuestions.remove(questionId)
                            
                            // Set user-visible error message
                            let errorMsg = "Upload failed for Part \(part), Q\(order): \(error.localizedDescription)"
                            self.errorMessage = errorMsg
                            
                            print("🔄 Removed questionId \(questionId) from uploaded set to allow retry")
                        }
                        
                        // Schedule automatic retry after a delay
                        Task {
                            try? await Task.sleep(nanoseconds: 5_000_000_000) // Wait 5 seconds
                            await self.retryUpload(sessionId: sessionId, questionId: questionId, audioURL: audioURL, part: part, order: order)
                        }
                    }
                }
                
                // Store task reference to prevent deallocation - this is crucial!
                self.activeUploadTasks.insert(uploadTask)
                print("🔒 Task stored in activeUploadTasks (\(self.activeUploadTasks.count) total active)")
                
                // Remove task from active set when complete (in background to avoid blocking)
                Task.detached { [weak self] in
                    await uploadTask.value // Wait for completion
                    await MainActor.run {
                        self?.activeUploadTasks.remove(uploadTask)
                        print("🗑️ Removed completed upload task. Active tasks: \(self?.activeUploadTasks.count ?? 0)")
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
        // Simple direct access: part and order are 1-based, convert to 0-based for array access
        let partIndex = part - 1      // Convert 1,2,3 -> 0,1,2
        let questionIndex = order - 1 // Convert 1,2,3 -> 0,1,2
        
        guard let partQuestions = questions[partIndex],
              questionIndex >= 0 && questionIndex < partQuestions.count else {
            print("⚠️ No question found for part \(part), order \(order) (partIndex: \(partIndex), questionIndex: \(questionIndex))")
            return nil
        }
        
        let questionId = partQuestions[questionIndex].id
        print("✅ Found question ID for part \(part), order \(order): \(questionId.prefix(8))...")
        return questionId
    }
    
    
    
    // MARK: - Upload Retry Logic
    
    /// Retry mechanism for failed uploads with exponential backoff
    private func retryUpload(sessionId: String, questionId: String, audioURL: URL, part: Int, order: Int, attempt: Int = 1) async {
        let maxRetries = 3
        
        guard attempt <= maxRetries else {
            print("❌ Max retries (\(maxRetries)) reached for Part \(part), Question \(order). Giving up.")
            await MainActor.run {
                self.errorMessage = "Upload failed permanently for Part \(part), Q\(order) after \(maxRetries) attempts"
            }
            return
        }
        
        print("🔄 Retry attempt \(attempt)/\(maxRetries) for Part \(part), Question \(order)")
        
        // Check if file still exists
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("❌ Audio file no longer exists for retry: \(audioURL.path)")
            await MainActor.run {
                self.errorMessage = "Audio file missing for Part \(part), Q\(order) retry"
            }
            return
        }
        
        // Prevent duplicate retries
        if uploadedQuestions.contains(questionId) {
            print("⏩ Question \(questionId) already uploaded, skipping retry")
            return
        }
        
        // Mark as being retried
        uploadedQuestions.insert(questionId)
        
        do {
            try await SupabaseService.shared.uploadResponse(
                sessionId: sessionId,
                questionId: questionId,
                audioURL: audioURL,
                part: part,
                order: order
            )
            
            print("✅ Retry successful: Part \(part), Question \(order) uploaded on attempt \(attempt)")
            
            await MainActor.run {
                // Clear error message on successful retry
                if let currentError = self.errorMessage, currentError.contains("Part \(part), Q\(order)") {
                    self.errorMessage = nil
                }
            }
            
        } catch {
            print("❌ Retry \(attempt) failed for Part \(part), Question \(order): \(error)")
            
            // Remove from uploaded set for next retry
            uploadedQuestions.remove(questionId)
            
            await MainActor.run {
                self.errorMessage = "Upload retry \(attempt)/\(maxRetries) failed for Part \(part), Q\(order)"
            }
            
            // Schedule next retry with exponential backoff
            if attempt < maxRetries {
                let backoffDelay = pow(2.0, Double(attempt)) * 3.0 // 3s, 6s, 12s delays
                let nanoseconds = UInt64(backoffDelay * 1_000_000_000)
                
                Task {
                    try? await Task.sleep(nanoseconds: nanoseconds)
                    await self.retryUpload(sessionId: sessionId, questionId: questionId, audioURL: audioURL, part: part, order: order, attempt: attempt + 1)
                }
            }
        }
    }
    
    
    
    
    
    private func nextQuestionOrPart() {
        print("🔄 NEXT_QUESTION_OR_PART CALLED:")
        print("   Before - Part: \(currentPart), QuestionIndex: \(currentQuestionIndex)")
        
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
            print("   Processing Part 1 transition...")
            currentQuestionIndex += 1
            print("   After increment - Part: \(currentPart), QuestionIndex: \(currentQuestionIndex)")
            if currentQuestionIndex < (questions[0]?.count ?? 0) {
                print("TestSimulationManager: Moving to next question in Part 1. Index: \(currentQuestionIndex)")
                // Add a small delay to ensure clean state transition
                DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.stateTransitionDelay) {
                    self.startConversationFlow()
                }
            } else {
                print("   🎯 PART 1 -> 2 TRANSITION:")
                print("     All Part 1 questions covered. Moving to Part 2.")
                currentPart = 2
                currentQuestionIndex = 0
                print("     After transition - Part: \(currentPart), QuestionIndex: \(currentQuestionIndex)")
                DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.stateTransitionDelay) {
                    self.startConversationFlow()
                }
            }
        } else if currentPart == 2 {
            print("   🎯 PART 2 -> 3 TRANSITION:")
            print("     Moving from Part 2 to Part 3.")
            currentPart = 3
            currentQuestionIndex = 0
            print("     After transition - Part: \(currentPart), QuestionIndex: \(currentQuestionIndex)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startConversationFlow()
            }
        } else if currentPart == 3 {
            print("   Processing Part 3 transition...")
            currentQuestionIndex += 1
            print("   After increment - Part: \(currentPart), QuestionIndex: \(currentQuestionIndex)")
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
            // Wait for all active upload tasks to complete before proceeding
            print("🔄 Finalizing test - waiting for \(activeUploadTasks.count) active upload tasks to complete...")
            
            if !activeUploadTasks.isEmpty {
                let startTime = Date()
                
                // Wait for all uploads with timeout
                await withTaskGroup(of: Void.self) { group in
                    for task in activeUploadTasks {
                        group.addTask {
                            await task.value
                        }
                    }
                    // Add timeout task
                    group.addTask {
                        try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 second timeout
                    }
                }
                
                let elapsed = Date().timeIntervalSince(startTime)
                print("⏱️ Waited \(String(format: "%.2f", elapsed))s for uploads to complete")
            }
            
            // Additional delay for final uploads to complete
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
