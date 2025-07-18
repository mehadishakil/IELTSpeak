//
//  prev.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 18/7/25.
//




import Foundation
import AVFoundation
import Combine
import SwiftUI // Ensure this is imported for @Published if using in a separate file for TestSimulationManager

// MARK: - AudioPlayerManager
class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying: Bool = false
    @Published var currentAudioDuration: TimeInterval = 0
    @Published var currentPlaybackTime: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var tempAudioFileURL: URL?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("AudioPlayerManager: AVAudioSession set to playback and activated.")
        } catch {
            print("AudioPlayerManager: Failed to set up audio session for playback: \(error.localizedDescription)")
        }
    }

    func playAudio(from audioData: Data) {
        guard !isPlaying else {
            print("AudioPlayerManager: Audio already playing, ignoring new request.")
            return
        }

        stopAudio()

        do {
            let tempFilename = ProcessInfo.processInfo.globallyUniqueString + ".m4a"
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(tempFilename)

            try audioData.write(to: tempFileURL, options: .atomic)
            self.tempAudioFileURL = tempFileURL
            print("AudioPlayerManager: Wrote audio data (\(audioData.count) bytes) to temporary file: \(tempFileURL.lastPathComponent)")

            audioPlayer = try AVAudioPlayer(contentsOf: tempFileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            currentAudioDuration = audioPlayer?.duration ?? 0
            currentPlaybackTime = 0

            if audioPlayer?.play() == true {
                isPlaying = true
                startPlaybackTimer()
                print("AudioPlayerManager: Successfully started playing audio from: \(tempFileURL.lastPathComponent)")
            } else {
                print("AudioPlayerManager: Failed to call play() on AVAudioPlayer.")
                isPlaying = false
                cleanupTempAudioFile()
            }
        } catch {
            print("AudioPlayerManager: Error playing audio from Data: \(error.localizedDescription)")
            isPlaying = false
            cleanupTempAudioFile()
        }
    }

    func stopAudio() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            print("AudioPlayerManager: Audio explicitly stopped.")
        }
        isPlaying = false
        stopPlaybackTimer()
        cleanupTempAudioFile()
    }

    private func startPlaybackTimer() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePlaybackTime))
        displayLink?.add(to: .current, forMode: .common)
    }

    private func stopPlaybackTimer() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updatePlaybackTime() {
        currentPlaybackTime = audioPlayer?.currentTime ?? 0
    }

    private func cleanupTempAudioFile() {
        if let url = tempAudioFileURL {
            do {
                try FileManager.default.removeItem(at: url)
                print("AudioPlayerManager: Cleaned up temporary audio file: \(url.lastPathComponent)")
            } catch {
                print("AudioPlayerManager: Error cleaning up temporary audio file \(url.lastPathComponent): \(error.localizedDescription)")
            }
            tempAudioFileURL = nil
        }
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopPlaybackTimer()
        cleanupTempAudioFile()
        print("AudioPlayerManager: Audio finished playing. Success: \(flag)")
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        stopPlaybackTimer()
        cleanupTempAudioFile()
        print("AudioPlayerManager: Audio decode error: \(error?.localizedDescription ?? "unknown")")
    }

    deinit {
        stopAudio()
    }
}

// MARK: - AudioRecorderManager
class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording: Bool = false
    @Published var recordingTime: TimeInterval = 0
    @Published var recordingURL: URL?
    @Published var averagePower: Float = 0

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var currentRecordedAudioURL: URL?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            audioSession.requestRecordPermission { [weak self] allowed in
                if !allowed {
                    print("AudioRecorderManager: Microphone access denied.")
                } else {
                    print("AudioRecorderManager: Microphone access granted.")
                }
            }
            print("AudioRecorderManager: AVAudioSession set to playAndRecord and activated.")
        } catch {
            print("AudioRecorderManager: Failed to set up audio session for recording: \(error.localizedDescription)")
        }
    }

    func startRecording() throws {
        guard !isRecording else {
            print("AudioRecorderManager: Already recording.")
            return
        }

        // Always attempt to set the category and activate the session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("AudioRecorderManager: Ensured audio session is active for recording.")
        } catch {
            print("AudioRecorderManager: Failed to set or activate audio session for recording: \(error.localizedDescription)")
            throw error // Propagate error if session cannot be activated
        }

        let audioFilename = getDocumentsDirectory().appendingPathComponent(UUID().uuidString + ".m4a")
        currentRecordedAudioURL = audioFilename

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()

            if audioRecorder?.record() == true {
                isRecording = true
                recordingTime = 0
                startRecordingTimer()
                print("AudioRecorderManager: Recording started to: \(audioFilename.lastPathComponent)")
            } else {
                isRecording = false
                print("AudioRecorderManager: Failed to start recording (record() returned false).")
            }
        } catch {
            isRecording = false
            print("AudioRecorderManager: Error starting recording: \(error.localizedDescription)")
            throw error
        }
    }

    func stopRecording() -> URL? {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            print("AudioRecorderManager: Recording stopped.")
        } else {
            print("AudioRecorderManager: Stop recording called but not actively recording.")
        }
        isRecording = false
        stopRecordingTimer()
        recordingURL = currentRecordedAudioURL
        return currentRecordedAudioURL
    }

    private func startRecordingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingTime += 0.1
            self.audioRecorder?.updateMeters()
            let linearPower = pow(
                10,
                (self.audioRecorder?.averagePower(forChannel: 0) ?? -160) / 20
            )
            self.averagePower = linearPower
        }
    }

    private func stopRecordingTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        isRecording = false
        stopRecordingTimer()
        print("AudioRecorderManager: Recording finished. Success: \(flag)")
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        isRecording = false
        stopRecordingTimer()
        print("AudioRecorderManager: Audio recorder error: \(error?.localizedDescription ?? "unknown")")
    }
}

// MARK: - SpeechRecognizerManager
class SpeechRecognizerManager: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isRecognizing: Bool = false
    @Published var isSpeechDetected: Bool = false
    @Published var lastTranscript: String = ""
    @Published var error: String?

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var silenceTimer: Timer?

    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }

    func isSpeechRecognitionAvailable() -> Bool {
        return speechRecognizer?.isAvailable ?? false
    }

    private func setupAudioSessionForSpeechRecognition() throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("SpeechRecognizerManager: AVAudioSession set to record and activated for speech recognition.")
        } catch {
            print("SpeechRecognizerManager: Audio session setup failed for speech recognition: \(error.localizedDescription)")
            throw SpeechRecognizerError.audioSessionSetupFailed(error.localizedDescription)
        }
    }

    func startSpeechRecognition(
        silenceDetectionDuration: TimeInterval = 2.0,
        onSpeechStart: @escaping () -> Void,
        onSpeechEnd: @escaping (String) -> Void
    ) throws {
        guard isSpeechRecognitionAvailable() else {
            throw SpeechRecognizerError.notAvailable
        }
        guard error == nil else {
            throw SpeechRecognizerError.authorizationDenied
        }

        stopSpeechRecognition(shouldCallCompletion: false)

        isRecognizing = true
        isSpeechDetected = false
        lastTranscript = ""
        error = nil

        try setupAudioSessionForSpeechRecognition()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognizerError.requestCreationFailed
        }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                self.lastTranscript = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("SpeechRecognizerManager: Partial Transcript: \(self.lastTranscript)")

                if !self.isSpeechDetected {
                    self.isSpeechDetected = true
                    onSpeechStart()
                    print("SpeechRecognizerManager: Speech detected! Calling onSpeechStart.")
                }
                
                self.silenceTimer?.invalidate()
                self.silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceDetectionDuration, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    print("SpeechRecognizerManager: Silence detected for \(silenceDetectionDuration) seconds. Calling onSpeechEnd.")
                    self.isSpeechDetected = false
                    self.stopSpeechRecognition(shouldCallCompletion: true, completionText: self.lastTranscript)
                    onSpeechEnd(self.lastTranscript)
                }
            }

            if error != nil || isFinal {
                if let error = error {
                    print("SpeechRecognizerManager: Recognition task error: \(error.localizedDescription)")
                    self.error = "Speech recognition error: \(error.localizedDescription)"
                }
                if isFinal && result == nil {
                    self.stopSpeechRecognition(shouldCallCompletion: true, completionText: self.lastTranscript)
                    onSpeechEnd(self.lastTranscript)
                }
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            print("SpeechRecognizerManager: Audio engine started for speech recognition.")
        } catch {
            stopSpeechRecognition(shouldCallCompletion: false)
            throw SpeechRecognizerError.audioEngineFailed(error.localizedDescription)
        }
    }

    func stopSpeechRecognition(shouldCallCompletion: Bool = false, completionText: String = "") {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            print("SpeechRecognizerManager: Audio engine stopped.")
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        silenceTimer?.invalidate()
        silenceTimer = nil

        isRecognizing = false
        isSpeechDetected = false
        print("SpeechRecognizerManager: Speech recognition resources cleared.")

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("SpeechRecognizerManager: AVAudioSession deactivated.")
        } catch {
            print("SpeechRecognizerManager: Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidRecognize: Bool) {
        if !availabilityDidRecognize {
            self.error = "Speech recognition is not currently available."
            print("SpeechRecognizerManager: Speech recognizer availability changed: NOT available.")
        } else {
            self.error = nil
            print("SpeechRecognizerManager: Speech recognizer availability changed: AVAILABLE.")
        }
    }

    // MARK: - Custom Errors
    enum SpeechRecognizerError: LocalizedError {
        case notAvailable
        case authorizationDenied
        case requestCreationFailed
        case audioEngineFailed(String)
        case audioSessionSetupFailed(String)

        var errorDescription: String? {
            switch self {
            case .notAvailable: return "Speech recognition is not available on this device or for this locale."
            case .authorizationDenied: return "Microphone access or speech recognition authorization denied."
            case .requestCreationFailed: return "Failed to create speech recognition request."
            case .audioEngineFailed(let message): return "Audio engine failed: \(message)"
            case .audioSessionSetupFailed(let message): return "Audio session setup failed: \(message)"
            }
        }
    }
}

// MARK: - TestSimulationManager
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
        setupBindings()
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
        
        audioPlayerManager.$isPlaying
            .filter { !$0 && self.isExaminerSpeaking }
            .sink { [weak self] _ in
                if self?.errorMessage == nil {
                }
            }
            .store(in: &cancellables)
    }

    func startTest() {
        currentPhase = .testing
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
        guard currentPhase == .testing else { return }

        audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition()
        audioPlayerManager.stopAudio()
        part2SpeakingTimer?.invalidate()
        preparationTimer?.invalidate()
        print("TestSimulationManager: Cleaned up previous states.")


        if currentPart == 1 {
            guard let part1Questions = questions[0], currentQuestionIndex < part1Questions.count else {
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

        } else if currentPart == 2 {
            guard let part2Questions = questions[1], !part2Questions.isEmpty else {
                print("TestSimulationManager: Part 2 finished or no questions. Moving to Part 3.")
                currentPart = 3
                currentQuestionIndex = 0
                startConversationFlow()
                return
            }
            let cueCard = part2Questions[0]
            currentQuestionText = cueCard.questionText
            print("TestSimulationManager: Part 2: Playing cue card audio for '\(currentQuestionText.prefix(30))...'")
            playExaminerQuestion(cueCard.audioFile, part: currentPart, questionText: cueCard.questionText) { [weak self] in
                self?.startPart2Preparation()
            }

        } else if currentPart == 3 {
            guard let part3Questions = questions[2], currentQuestionIndex < part3Questions.count else {
                print("TestSimulationManager: Part 3 finished. Moving to Processing.")
                currentPhase = .processing
                return
            }
            let question = part3Questions[currentQuestionIndex]
            currentQuestionText = question.questionText
            print("TestSimulationManager: Part 3, Question \(currentQuestionIndex + 1): Playing examiner audio for '\(currentQuestionText.prefix(30))...'")
            playExaminerQuestion(question.audioFile, part: currentPart, questionText: question.questionText, silenceDuration: 3.5)

        } else {
            print("TestSimulationManager: Test flow completed or invalid part. Finalizing.")
            currentPhase = .processing
        }
    }

    private func playExaminerQuestion(_ audioData: Data, part: Int, questionText: String, silenceDuration: TimeInterval = 2.0, completion: (() -> Void)? = nil) {
        
        var audioPlaybackCancellable: AnyCancellable?
        audioPlaybackCancellable = audioPlayerManager.$isPlaying
            .filter { !$0 }
            .prefix(1)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("TestSimulationManager: Examiner audio finished or failed to play. isPlaying is now false. Current Part: \(self.currentPart)")
                completion?()

                if self.currentPart != 2 || (self.currentPart == 2 && self.part2PreparationTimeRemaining <= 0) {
                    print("TestSimulationManager: Starting user response recording.")
                    self.startUserResponseRecording(silenceDuration: silenceDuration, part: part, questionText: questionText)
                }
                audioPlaybackCancellable?.cancel()
            }
        audioPlaybackCancellable?.store(in: &cancellables)
        
        audioPlayerManager.playAudio(from: audioData)
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
                self.stopUserResponseAndSave(part: self.currentPart, questionText: self.currentQuestionText)
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
                            self.stopUserResponseAndSave(part: part, questionText: questionText, transcript: transcript)
                            self.part2SpeakingTimer?.invalidate()
                            self.part2SpeakingTimer = nil
                            self.nextQuestionOrPart()
                        } else if self.recordingTime < 60 {
                            print("TestSimulationManager: Part 2: User stopped speaking before 1 minute. Saving and proceeding.")
                            self.stopUserResponseAndSave(part: part, questionText: questionText, transcript: transcript)
                            self.part2SpeakingTimer?.invalidate()
                            self.part2SpeakingTimer = nil
                            self.nextQuestionOrPart()
                        }
                    } else {
                        print("TestSimulationManager: Part \(part): User stopped speaking. Saving and proceeding.")
                        self.stopUserResponseAndSave(part: part, questionText: questionText, transcript: transcript)
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

    private func stopUserResponseAndSave(part: Int, questionText: String, transcript: String = "") {
        let recordedURL = audioRecorderManager.stopRecording()
        speechRecognizerManager.stopSpeechRecognition(shouldCallCompletion: false)

        let answerText = transcript.isEmpty ? "(No speech detected or transcribed)" : transcript

        DispatchQueue.global(qos: .background).async { [weak self] in
            let newConversation = Conversation(
                part: part,
                question: questionText,
                answer: answerText,
                errors: []
            )
            DispatchQueue.main.async {
                self?.conversations.append(newConversation)
                print("TestSimulationManager: Saved conversation for Part \(part), Question: '\(questionText.prefix(30))...'")
                if let url = recordedURL {
                    print("TestSimulationManager: Recorded audio saved to: \(url.lastPathComponent)")
                } else {
                    print("TestSimulationManager: No audio recorded for this response.")
                }
            }
        }
    }

    private func nextQuestionOrPart() {
        preparationTimer?.invalidate()
        part2SpeakingTimer?.invalidate()
        
        if currentPart == 1 {
            currentQuestionIndex += 1
            if currentQuestionIndex < (questions[0]?.count ?? 0) {
                print("TestSimulationManager: Moving to next question in Part 1. Index: \(currentQuestionIndex)")
                startConversationFlow()
            } else {
                print("TestSimulationManager: All Part 1 questions covered. Initiating Part 2 transition.")
                currentPart = 2
                currentQuestionIndex = 0
                startConversationFlow()
            }
        } else if currentPart == 2 {
            print("TestSimulationManager: Moving from Part 2 to Part 3.")
            currentPart = 3
            currentQuestionIndex = 0
            startConversationFlow()
        } else if currentPart == 3 {
            currentQuestionIndex += 1
            if currentQuestionIndex < (questions[2]?.count ?? 0) {
                print("TestSimulationManager: Moving to next question in Part 3. Index: \(currentQuestionIndex)")
                startConversationFlow()
            } else {
                print("TestSimulationManager: All Part 3 questions covered. Initiating test finalization.")
                currentPhase = .processing
            }
        } else {
            print("TestSimulationManager: nextQuestionOrPart called in unexpected state, finalizing test.")
            currentPhase = .processing
        }
    }

    // MARK: - Test Completion
    func finalizeTest() {
        currentPhase = .completed
        print("TestSimulationManager: Test completed. Final conversations: \(conversations.count)")
    }
}

import SwiftUI
import Speech

struct TestSimulatorScreen: View {
    @StateObject private var testManager: TestSimulationManager // Use StateObject for manager lifecycle
    @Environment(\.dismiss) private var dismiss

    let questions: [Int: [QuestionItem]] // Passed from the calling view

    init(questions: [Int: [QuestionItem]]) {
        self.questions = questions
        // Initialize StateObject AFTER self is initialized
        _testManager = StateObject(wrappedValue: TestSimulationManager(questions: questions))
        print(questions)
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
                            showQuestions: .constant(true), // Assuming showQuestions is always true for now
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
                            userWaveformData: testManager.audioRecorderManager.isRecording ? generateUserVisualWaveformData(power: testManager.audioRecorderManager.averagePower) : Array(repeating: 0.0, count: 30),
                            part2PreparationTimeRemaining: testManager.part2PreparationTimeRemaining, // Pass Part 2 specific times
                            part2SpeakingTimeRemaining: testManager.part2SpeakingTimeRemaining
                        )
                        // No .onAppear here for starting flow, testManager handles it
                        // The flow is started by testManager.startTest()
                        // and then progresses based on internal state changes.

                    case .processing:
                        TestProcessingView(isProcessing: .constant(true)) // Assuming processing once entered
                            .onAppear {
                                // Simulate processing time
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    testManager.finalizeTest()
                                }
                            }
                    case .completed:
                        TestCompletedView(onViewResults: {
                            dismiss()
                            // In a real app, you would navigate to a results screen here
                            // You could pass testManager.conversations to the results view
                        })
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: - Waveform Generation Helpers (moved from TestSimulatorScreen)
    // These now use the manager's published properties
    private func generateVisualWaveformData(for currentTime: TimeInterval, duration: TimeInterval, isSpeaking: Bool) -> [Double] {
        guard isSpeaking && duration > 0 else { return Array(repeating: 0.0, count: 50) }
        let progress = currentTime / duration
        let activeBarCount = Int(progress * Double(50))
        var data = Array(repeating: 0.0, count: 50)
        for i in 0..<50 {
            if i < activeBarCount {
                data[i] = Double.random(in: 0.3...1.0) // Simulates active sound
            } else {
                data[i] = 0.1 // Simulates background or silence
            }
        }
        return data
    }

    private func generateUserVisualWaveformData(power: Float) -> [Double] {
        var data = Array(repeating: 0.0, count: 30)
        let normalizedPower = max(0.0, min(1.0, power)) // Clamp between 0 and 1
        for i in 0..<30 {
            // Scale the power to a visual range for the bars
            data[i] = Double(normalizedPower) * Double.random(in: 0.5...1.0)
        }
        return data
    }
}

struct ExamTestView: View {
    let currentPart: Int
    let currentQuestionText: String
    let isExaminerSpeaking: Bool
    let isUserSpeaking: Bool
    let isRecording: Bool
    let recordingTime: TimeInterval
    let waveformData: [Double]
    let userWaveformData: [Double]
    let part2PreparationTimeRemaining: TimeInterval
    let part2SpeakingTimeRemaining: TimeInterval

    var formattedRecordingTime: String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            if currentPart == 2 && part2PreparationTimeRemaining > 0 {
                VStack {
                    Text("Preparation Time Remaining:")
                        .font(.headline)
                    Text(String(format: "%02d:%02d", Int(part2PreparationTimeRemaining) / 60, Int(part2PreparationTimeRemaining) % 60))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    ProgressView(value: 60 - part2PreparationTimeRemaining, total: 60)
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                        .padding(.horizontal)
                }
                .transition(.opacity)
            } else if currentPart == 2 && part2SpeakingTimeRemaining > 0 {
                VStack {
                    Text("Speaking Time Remaining (Max 2:00):")
                        .font(.headline)
                    Text(String(format: "%02d:%02d", Int(part2SpeakingTimeRemaining) / 60, Int(part2SpeakingTimeRemaining) % 60))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(part2SpeakingTimeRemaining <= 30 ? .red : .accentColor)
                    ProgressView(value: 120 - part2SpeakingTimeRemaining, total: 120)
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                        .padding(.horizontal)
                }
                .transition(.opacity)
            }


            Text("Examiner's Question:")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(currentQuestionText)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(minHeight: 80) // Give it a fixed minimum height to prevent jumpiness

            if isExaminerSpeaking {
                WaveformView(amplitudes: waveformData, color: .blue)
                    .frame(height: 50)
                    .padding(.horizontal)
                    .transition(.opacity)
            } else {
                Text("Waiting for your response...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .opacity(isRecording ? 0 : 1) // Hide if recording starts
                    .transition(.opacity)
            }

            Spacer()

            if isRecording {
                VStack {
                    Text("Your Response:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(formattedRecordingTime)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    WaveformView(amplitudes: userWaveformData, color: .green)
                        .frame(height: 50)
                        .padding(.horizontal)
                }
                .transition(.opacity) // Animate appearance
            } else {
                Image(systemName: "mic.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(height: 50)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }
}
//
//// Simple WaveformView (can be enhanced)
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
        // In a real app, this data would come from your backend/downloaded files.
        let dummyAudioData = "dummy audio data for testing".data(using: .utf8)! // Replace with actual audio data if possible for better testing

        let mockTestQuestions: [Int: [QuestionItem]] = [
            0: [ // Part 1
                QuestionItem(part: 1, order: 1, questionText: "Let's talk about your hometown. Where are you from?", audioFile: dummyAudioData),
                QuestionItem(part: 1, order: 2, questionText: "What do you like most about your hometown?", audioFile: dummyAudioData),
                QuestionItem(part: 1, order: 3, questionText: "Is there anything you would like to change about it?", audioFile: dummyAudioData)
            ],
            1: [ // Part 2 (Cue Card)
                QuestionItem(part: 1, order: 1, questionText: """
                Describe a time you helped someone.
                You should say:
                - who you helped
                - what the situation was
                - how you helped them
                and explain how you felt after helping this person.
                """, audioFile: dummyAudioData)
            ],
            2: [ // Part 3
                QuestionItem(part: 1, order: 1, questionText: "Let's discuss helping others in general. Why do people choose to help others?", audioFile: dummyAudioData),
                QuestionItem(part: 1, order: 2, questionText: "Do you think people today are more or less willing to help others compared to the past?", audioFile: dummyAudioData),
                QuestionItem(part: 1, order: 3, questionText: "What are some of the benefits of volunteering in the community?", audioFile: dummyAudioData)
            ]
        ]

        TestSimulatorScreen(questions: mockTestQuestions)
            .environment(\.colorScheme, .light) // Example for light mode
    }
}
