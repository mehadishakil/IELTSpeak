import SwiftUI

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
        .ignoresSafeArea(.all)
        .toolbar(.hidden, for: .tabBar)
    }

}

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






//
//import SwiftUI
//
//struct TestSimulatorScreen: View {
//    @State private var currentPhase: TestPhase = .preparation
//    @State private var currentPart: Int = 1
//    @State private var currentQuestion: Int = 0
//    @State private var isRecording: Bool = false
//    @State private var showWaveform: Bool = false
//    @State private var recordingTime: TimeInterval = 0
//    @State private var timer: Timer?
//    @State private var waveformData: [Double] = Array(repeating: 0.0, count: 50)
//    @State private var showQuestions: Bool = true
//    @State private var isProcessing: Bool = false
//    @State private var showResults: Bool = false
//    @State private var isUserSpeaking: Bool = false
//    @State private var userWaveformData: [Double] = Array(repeating: 0.0, count: 30)
//    @State private var isExaminerSpeaking: Bool = false
//    @Environment(\.dismiss) private var dismiss
//    
//    let questions: [Int: [QuestionItem]]
//    
//    var currentTestPart: TestPart {
//        testQuestions[currentPart - 1]
//    }
//    
//    var currentQuestionText: String {
//        guard currentQuestion < currentTestPart.questions.count else { return "" }
//        return currentTestPart.questions[currentQuestion]
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(.systemBackground)
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    TestHeaderView(
//                        currentPhase: currentPhase,
//                        currentPart: currentPart,
//                        onDismiss: { dismiss() }
//                    )
//                    
//                    switch currentPhase {
//                    case .preparation:
//                        TestPreparationView(
//                            showQuestions: $showQuestions,
//                            onStartTest: startTest
//                        )
//                    case .testing:
//                        ExamTestView(
//                            currentPart: currentPart,
//                            currentQuestionText: currentQuestionText,
//                            isExaminerSpeaking: isExaminerSpeaking,
//                            isUserSpeaking: isUserSpeaking,
//                            isRecording: isRecording,
//                            recordingTime: recordingTime,
//                            waveformData: waveformData,
//                            userWaveformData: userWaveformData
//                        )
//                        .onAppear {
//                            if currentPhase == .testing {
//                                startConversationFlow()
//                            }
//                        }
//                    case .processing:
//                        TestProcessingView(isProcessing: $isProcessing)
//                            .onAppear {
//                                isProcessing = true
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                    currentPhase = .completed
//                                    isProcessing = false
//                                }
//                            }
//                    case .completed:
//                        TestCompletedView(onViewResults: {
//                            dismiss()
//                        })
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .onAppear {
//                generateWaveformData()
//            }
//        }
//        .ignoresSafeArea()
//        .toolbar(.hidden, for: .tabBar)
//    }
//    
//    // MARK: - Helper Methods
//    private func startTest() {
//        currentPhase = .testing
//        showWaveform = true
//    }
//    
//    private func toggleRecording() {
//        isRecording.toggle()
//        isUserSpeaking = isRecording
//        
//        if isRecording {
//            startTimer()
//            generateUserWaveform()
//        } else {
//            stopTimer()
//        }
//    }
//    
//    private func nextQuestion() {
//        if currentQuestion < currentTestPart.questions.count - 1 {
//            currentQuestion += 1
//            startConversationFlow()
//        } else if currentPart < 3 {
//            currentPart += 1
//            currentQuestion = 0
//            startConversationFlow()
//        } else {
//            currentPhase = .processing
//        }
//    }
//    
//    private func startTimer() {
//        recordingTime = 0
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            recordingTime += 1
//        }
//    }
//    
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    private func generateWaveformData() {
//        if isExaminerSpeaking {
//            for i in 0..<waveformData.count {
//                waveformData[i] = Double.random(in: 0.1...1.0)
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                generateWaveformData()
//            }
//        }
//    }
//    
//    private func startConversationFlow() {
//        isUserSpeaking = false
//        isRecording = false
//        isExaminerSpeaking = true
//        
//        generateWaveformData()
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//            isExaminerSpeaking = false
//        }
//    }
//    
//    private func generateUserWaveform() {
//        if isUserSpeaking && isRecording {
//            for i in 0..<userWaveformData.count {
//                userWaveformData[i] = Double.random(in: 0.2...1.0)
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                generateUserWaveform()
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//struct TestSimulatorScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        // TestSimulatorScreen(questions: testQuestions)
//    }
//}





//
//import SwiftUI
//import AVFoundation
//import Speech
//
//// MARK: - Main Test Simulator Screen
//struct TestSimulatorScreen: View {
//    @State private var currentPhase: TestPhase = .preparation
//    @State private var currentPart: Int = 1
//    @State private var currentQuestion: Int = 0
//    @State private var isRecording: Bool = false
//    @State private var showWaveform: Bool = false
//    @State private var recordingTime: TimeInterval = 0
//    @State private var timer: Timer?
//    @State private var waveformData: [Double] = Array(repeating: 0.0, count: 50)
//    @State private var showQuestions: Bool = true
//    @State private var isProcessing: Bool = false
//    @State private var showResults: Bool = false
//    @State private var isUserSpeaking: Bool = false
//    @State private var userWaveformData: [Double] = Array(repeating: 0.0, count: 30)
//    @State private var isExaminerSpeaking: Bool = false
//    @State private var preparationTime: TimeInterval = 0
//    @State private var speakingTime: TimeInterval = 0
//    @StateObject private var speechRecognitionManager = SpeechRecognitionManager()
//    @StateObject private var audioPlaybackManager = AudioPlaybackManager()
//    @StateObject private var testResponseManager = TestResponseManager()
//    @Environment(\.dismiss) private var dismiss
//    
//    let questions: [Int: [QuestionItem]]
//    
//    var currentQuestionItem: QuestionItem? {
//        guard let partQuestions = questions[currentPart - 1],
//              currentQuestion < partQuestions.count else { return nil }
//        return partQuestions[currentQuestion]
//    }
//    
//    var currentQuestionText: String {
//        currentQuestionItem?.questionText ?? ""
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(.systemBackground)
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    TestHeaderView(
//                        currentPhase: currentPhase,
//                        currentPart: currentPart,
//                        onDismiss: { dismiss() }
//                    )
//                    
//                    switch currentPhase {
//                    case .preparation:
//                        TestPreparationView(
//                            showQuestions: $showQuestions,
//                            onStartTest: startTest
//                        )
//                    case .testing:
//                        ExamTestView(
//                            currentPart: currentPart,
//                            currentQuestionText: showQuestions ? currentQuestionText : "",
//                            isExaminerSpeaking: isExaminerSpeaking,
//                            isUserSpeaking: isUserSpeaking,
//                            isRecording: isRecording,
//                            recordingTime: recordingTime,
//                            waveformData: waveformData,
//                            userWaveformData: userWaveformData,
//                            preparationTime: preparationTime,
//                            speakingTime: speakingTime,
//                            showPreparationTimer: currentPart == 2 && preparationTime > 0,
//                            showSpeakingTimer: currentPart == 2 && speakingTime > 0
//                        )
//                    case .processing:
//                        TestProcessingView(isProcessing: $isProcessing)
//                            .onAppear {
//                                processTestCompletion()
//                            }
//                    case .completed:
//                        TestCompletedView(onViewResults: {
//                            dismiss()
//                        })
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .onAppear {
//                setupTestEnvironment()
//            }
//        }
//        .ignoresSafeArea()
//        .toolbar(.hidden, for: .tabBar)
//    }
//    
//    // MARK: - Setup Methods
//    private func setupTestEnvironment() {
//        // Set up callbacks instead of delegates
//        speechRecognitionManager.onSilenceDetected = { [weak speechRecognitionManager] in
//            self.handleSilenceDetected()
//        }
//        
//        audioPlaybackManager.onPlaybackFinished = { [weak audioPlaybackManager] in
//            self.handleAudioPlaybackFinished()
//        }
//        
//        generateWaveformData()
//    }
//    
//    private func handleSilenceDetected() {
//        // User has stopped speaking
//        stopRecording()
//    }
//    
//    private func handleAudioPlaybackFinished() {
//        isExaminerSpeaking = false
//        
//        // Start appropriate response handling based on current part
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            switch currentPart {
//            case 1:
//                handlePartOneQuestion()
//            case 2:
//                if preparationTime == 0 && speakingTime == 0 {
//                    handlePartTwoPreparation()
//                }
//            case 3:
//                handlePartThreeQuestion()
//            default:
//                break
//            }
//        }
//    }
//    
//    private func startTest() {
//        currentPhase = .testing
//        currentPart = 1
//        currentQuestion = 0
//        startPartOne()
//    }
//    
//    // MARK: - Part 1: General Introduction Questions
//    private func startPartOne() {
//        guard let questionItem = currentQuestionItem else {
//            moveToNextPart()
//            return
//        }
//        
//        playQuestionAudio(questionItem.audioFile)
//    }
//    
//    private func handlePartOneQuestion() {
//        startRecording()
//        speechRecognitionManager.startListening()
//    }
//    
//    // MARK: - Part 2: Cue Card
//    private func startPartTwo() {
//        guard let questionItem = currentQuestionItem else {
//            moveToNextPart()
//            return
//        }
//        
//        playQuestionAudio(questionItem.audioFile)
//    }
//    
//    private func handlePartTwoPreparation() {
//        // Start 1-minute preparation timer
//        preparationTime = 60
//        startPreparationTimer()
//    }
//    
//    private func startPreparationTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            if preparationTime > 0 {
//                preparationTime -= 1
//            } else {
//                timer?.invalidate()
//                startPartTwoSpeaking()
//            }
//        }
//    }
//    
//    private func startPartTwoSpeaking() {
//        preparationTime = 0
//        speakingTime = 120 // 2 minutes
//        
//        // Play prompt to start speaking
//        playPromptAudio("start_speaking")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            startRecording()
//            speechRecognitionManager.startListening()
//            startSpeakingTimer()
//        }
//    }
//    
//    private func startSpeakingTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            if speakingTime > 0 {
//                speakingTime -= 1
//            } else {
//                // Time's up - stop recording
//                timer?.invalidate()
//                stopRecording()
//                playPromptAudio("time_up")
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    moveToNextPart()
//                }
//            }
//        }
//    }
//    
//    // MARK: - Part 3: Follow-Up Questions
//    private func startPartThree() {
//        guard let questionItem = currentQuestionItem else {
//            completeTest()
//            return
//        }
//        
//        playQuestionAudio(questionItem.audioFile)
//    }
//    
//    private func handlePartThreeQuestion() {
//        startRecording()
//        speechRecognitionManager.startListening()
//    }
//    
//    // MARK: - Audio Management
//    private func playQuestionAudio(_ audioData: Data) {
//        isExaminerSpeaking = true
//        audioPlaybackManager.playAudio(audioData)
//    }
//    
//    private func playPromptAudio(_ prompt: String) {
//        isExaminerSpeaking = true
//        // Play system prompt audio
//        audioPlaybackManager.playPrompt(prompt)
//    }
//    
//    // MARK: - Recording Management
//    private func startRecording() {
//        isRecording = true
//        isUserSpeaking = true
//        recordingTime = 0
//        
//        testResponseManager.startRecording()
//        startRecordingTimer()
//        generateUserWaveform()
//    }
//    
//    private func stopRecording() {
//        isRecording = false
//        isUserSpeaking = false
//        
//        timer?.invalidate()
//        speechRecognitionManager.stopListening()
//        
//        // Save the response
//        if let questionItem = currentQuestionItem {
//            testResponseManager.saveResponse(
//                part: currentPart,
//                questionText: questionItem.questionText,
//                completion: { success in
//                    if success {
//                        moveToNextQuestion()
//                    }
//                }
//            )
//        }
//    }
//    
//    private func startRecordingTimer() {
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            recordingTime += 1
//        }
//    }
//    
//    // MARK: - Navigation Methods
//    private func moveToNextQuestion() {
//        let partQuestions = questions[currentPart - 1] ?? []
//        
//        if currentQuestion < partQuestions.count - 1 {
//            currentQuestion += 1
//            
//            // Small delay between questions
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                switch currentPart {
//                case 1:
//                    startPartOne()
//                case 2:
//                    // Part 2 only has one question (cue card)
//                    moveToNextPart()
//                case 3:
//                    startPartThree()
//                default:
//                    break
//                }
//            }
//        } else {
//            moveToNextPart()
//        }
//    }
//    
//    private func moveToNextPart() {
//        if currentPart < 3 {
//            currentPart += 1
//            currentQuestion = 0
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                switch currentPart {
//                case 2:
//                    startPartTwo()
//                case 3:
//                    startPartThree()
//                default:
//                    break
//                }
//            }
//        } else {
//            completeTest()
//        }
//    }
//    
//    private func completeTest() {
//        currentPhase = .processing
//    }
//    
//    private func processTestCompletion() {
//        isProcessing = true
//        
//        // Process all saved responses
//        testResponseManager.finalizeTest { success in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
//                isProcessing = false
//                currentPhase = .completed
//            }
//        }
//    }
//    
//    // MARK: - Waveform Generation
//    private func generateWaveformData() {
//        if isExaminerSpeaking {
//            for i in 0..<waveformData.count {
//                waveformData[i] = Double.random(in: 0.1...1.0)
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                generateWaveformData()
//            }
//        }
//    }
//    
//    private func generateUserWaveform() {
//        if isUserSpeaking && isRecording {
//            for i in 0..<userWaveformData.count {
//                userWaveformData[i] = Double.random(in: 0.2...1.0)
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                generateUserWaveform()
//            }
//        }
//    }
//}
//
//// MARK: - Speech Recognition Manager
//class SpeechRecognitionManager: NSObject, ObservableObject {
//    var onSilenceDetected: (() -> Void)?
//    private let speechRecognizer = SFSpeechRecognizer()
//    private let audioEngine = AVAudioEngine()
//    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
//    private var recognitionTask: SFSpeechRecognitionTask?
//    private var silenceTimer: Timer?
//    
//    func startListening() {
//        guard let speechRecognizer = speechRecognizer,
//              speechRecognizer.isAvailable else { return }
//        
//        setupAudioSession()
//        
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = recognitionRequest else { return }
//        
//        recognitionRequest.shouldReportPartialResults = true
//        
//        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
//            if let result = result {
//                self?.handleSpeechResult(result)
//            }
//            
//            if error != nil {
//                self?.stopListening()
//            }
//        }
//        
//        let inputNode = audioEngine.inputNode
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            recognitionRequest.append(buffer)
//        }
//        
//        audioEngine.prepare()
//        try? audioEngine.start()
//    }
//    
//    func stopListening() {
//        audioEngine.stop()
//        audioEngine.inputNode.removeTap(onBus: 0)
//        
//        recognitionRequest?.endAudio()
//        recognitionRequest = nil
//        recognitionTask?.cancel()
//        recognitionTask = nil
//        
//        silenceTimer?.invalidate()
//        silenceTimer = nil
//    }
//    
//    private func setupAudioSession() {
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
//        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//    }
//    
//    private func handleSpeechResult(_ result: SFSpeechRecognitionResult) {
//        // Reset silence timer when speech is detected
//        silenceTimer?.invalidate()
//        
//        if result.isFinal {
//            startSilenceTimer()
//        } else {
//            // Start silence timer for partial results
//            startSilenceTimer()
//        }
//    }
//    
//    private func startSilenceTimer() {
//        silenceTimer?.invalidate()
//        silenceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
//            // User has stopped speaking for 3 seconds
//            self?.onSilenceDetected?()
//        }
//    }
//}
//
//// MARK: - Audio Playback Manager
//class AudioPlaybackManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
//    var onPlaybackFinished: (() -> Void)?
//    private var audioPlayer: AVAudioPlayer?
//    
//    func playAudio(_ audioData: Data) {
//        do {
//            audioPlayer = try AVAudioPlayer(data: audioData)
//            audioPlayer?.delegate = self
//            audioPlayer?.play()
//        } catch {
//            print("Error playing audio: \(error)")
//            onPlaybackFinished?()
//        }
//    }
//    
//    func playPrompt(_ prompt: String) {
//        // Play system prompt audio
//        // In a real implementation, you would have pre-recorded prompt audio files
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.onPlaybackFinished?()
//        }
//    }
//    
//    // MARK: - AVAudioPlayerDelegate
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        onPlaybackFinished?()
//    }
//}
//
//// MARK: - Test Response Manager
//class TestResponseManager: ObservableObject {
//    private var audioRecorder: AVAudioRecorder?
//    private var currentRecordingURL: URL?
//    private var testResponses: [TestResponse] = []
//    
//    func startRecording() {
//        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let audioFilename = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
//        
//        let settings = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//        
//        do {
//            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//            audioRecorder?.record()
//            currentRecordingURL = audioFilename
//        } catch {
//            print("Error starting recording: \(error)")
//        }
//    }
//    
//    func saveResponse(part: Int, questionText: String, completion: @escaping (Bool) -> Void) {
//        audioRecorder?.stop()
//        
//        guard let recordingURL = currentRecordingURL else {
//            completion(false)
//            return
//        }
//        
//        // Save response asynchronously
//        DispatchQueue.global(qos: .background).async {
//            let response = TestResponse(
//                part: part,
//                questionText: questionText,
//                audioFileURL: recordingURL,
//                timestamp: Date()
//            )
//            
//            self.testResponses.append(response)
//            
//            DispatchQueue.main.async {
//                completion(true)
//            }
//        }
//    }
//    
//    func finalizeTest(completion: @escaping (Bool) -> Void) {
//        // Process all responses and prepare for analysis
//        DispatchQueue.global(qos: .background).async {
//            // Here you would typically:
//            // 1. Upload audio files to server
//            // 2. Process responses for analysis
//            // 3. Generate test results
//            
//            DispatchQueue.main.async {
//                completion(true)
//            }
//        }
//    }
//}
//
//// MARK: - Enhanced ExamTestView
//struct ExamTestView: View {
//    let currentPart: Int
//    let currentQuestionText: String
//    let isExaminerSpeaking: Bool
//    let isUserSpeaking: Bool
//    let isRecording: Bool
//    let recordingTime: TimeInterval
//    let waveformData: [Double]
//    let userWaveformData: [Double]
//    let preparationTime: TimeInterval
//    let speakingTime: TimeInterval
//    let showPreparationTimer: Bool
//    let showSpeakingTimer: Bool
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            ExaminerSection(
//                currentQuestionText: currentQuestionText,
//                isExaminerSpeaking: isExaminerSpeaking,
//                waveformData: waveformData
//            )
//            
//            if showPreparationTimer {
//                PreparationTimerView(timeRemaining: preparationTime)
//            } else if showSpeakingTimer {
//                SpeakingTimerView(timeRemaining: speakingTime)
//            } else {
//                ProgressBarDivider(currentPart: currentPart)
//            }
//            
//            StudentSection(
//                isUserSpeaking: isUserSpeaking,
//                isRecording: isRecording,
//                recordingTime: recordingTime,
//                userWaveformData: userWaveformData
//            )
//        }
//    }
//}
//
//// MARK: - Timer Views
//struct PreparationTimerView: View {
//    let timeRemaining: TimeInterval
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text("Preparation Time")
//                .font(.caption)
//                .foregroundColor(.secondary)
//            
//            Text("\(Int(timeRemaining / 60)):\(String(format: "%02d", Int(timeRemaining.truncatingRemainder(dividingBy: 60))))")
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(.orange)
//            
//            ProgressView(value: (60 - timeRemaining) / 60)
//                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
//                .frame(height: 4)
//        }
//        .padding()
//        .background(Color(.systemGray6))
//    }
//}
//
//struct SpeakingTimerView: View {
//    let timeRemaining: TimeInterval
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text("Speaking Time")
//                .font(.caption)
//                .foregroundColor(.secondary)
//            
//            Text("\(Int(timeRemaining / 60)):\(String(format: "%02d", Int(timeRemaining.truncatingRemainder(dividingBy: 60))))")
//                .font(.title2)
//                .fontWeight(.bold)
//                .foregroundColor(timeRemaining > 30 ? .green : .red)
//            
//            ProgressView(value: (120 - timeRemaining) / 120)
//                .progressViewStyle(LinearProgressViewStyle(tint: timeRemaining > 30 ? .green : .red))
//                .frame(height: 4)
//        }
//        .padding()
//        .background(Color(.systemGray6))
//    }
//}
//
//// MARK: - Data Models
//struct TestResponse {
//    let part: Int
//    let questionText: String
//    let audioFileURL: URL
//    let timestamp: Date
//}
//
//// MARK: - Preview
//struct TestSimulatorScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TestSimulatorScreen(questions: [:])
//    }
//}
//
//
//
