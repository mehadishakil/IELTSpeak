import Foundation
import Foundation
import AVFoundation
import Combine
import SwiftUI
import Speech

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying: Bool = false
    @Published var currentAudioDuration: TimeInterval = 0
    @Published var currentPlaybackTime: TimeInterval = 0

    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    private var tempAudioFileURL: URL?
    private var playbackCompletionHandler: (() -> Void)?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            // Use .playAndRecord to be compatible with recording
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            print("AudioPlayerManager: AVAudioSession set to playAndRecord and activated.")
        } catch {
            print("AudioPlayerManager: Failed to set up audio session for playback: \(error.localizedDescription)")
        }
    }

    func playAudio(from audioData: Data, completion: (() -> Void)? = nil) {
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

            // Store the completion handler
            self.playbackCompletionHandler = completion
            
            if audioPlayer?.play() == true {
                isPlaying = true
                startPlaybackTimer()
                print("AudioPlayerManager: Successfully started playing audio from: \(tempFileURL.lastPathComponent)")
            } else {
                print("AudioPlayerManager: Failed to call play() on AVAudioPlayer.")
                isPlaying = false
                playbackCompletionHandler = nil
                cleanupTempAudioFile()
            }
        } catch {
            print("AudioPlayerManager: Error playing audio from Data: \(error.localizedDescription)")
            isPlaying = false
            playbackCompletionHandler = nil
            cleanupTempAudioFile()
        }
    }

    func stopAudio() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            print("AudioPlayerManager: Audio explicitly stopped.")
        }
        isPlaying = false
        playbackCompletionHandler = nil
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
        
        // Call completion handler if it exists
        if let completion = playbackCompletionHandler {
            playbackCompletionHandler = nil
            completion()
            print("AudioPlayerManager: Called completion handler after audio finished.")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        stopPlaybackTimer()
        cleanupTempAudioFile()
        print("AudioPlayerManager: Audio decode error: \(error?.localizedDescription ?? "unknown")")
        
        // Clear completion handler on error
        playbackCompletionHandler = nil
    }

    deinit {
        stopAudio()
    }
}

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

        // WAV Format (Commented out - now using AAC .m4a)
        // let audioFilename = getDocumentsDirectory().appendingPathComponent(UUID().uuidString + ".wav")
        // currentRecordedAudioURL = audioFilename

        // WAV PCM settings - mono, 16kHz (COMMENTED OUT)
        // let settings = [
        //     AVFormatIDKey: Int(kAudioFormatLinearPCM),        // Changed to Linear PCM
        //     AVSampleRateKey: 16000,                           // 16kHz sample rate
        //     AVNumberOfChannelsKey: 1,                         // Mono
        //     AVLinearPCMBitDepthKey: 16,                       // 16-bit depth
        //     AVLinearPCMIsBigEndianKey: false,                 // Little endian
        //     AVLinearPCMIsFloatKey: false,                     // Integer samples
        //     AVLinearPCMIsNonInterleaved: false                // Interleaved
        // ] as [String : Any]

        // AAC .m4a format (Apple default - optimized for size and quality)
        let audioFilename = getDocumentsDirectory().appendingPathComponent(UUID().uuidString + ".m4a")
        currentRecordedAudioURL = audioFilename

        // AAC settings - mono, 16kHz, optimized compression
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),         // AAC format
            AVSampleRateKey: 16000,                           // 16kHz sample rate
            AVNumberOfChannelsKey: 1,                         // Mono
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,  // High quality
            AVEncoderBitRateKey: 32000                        // 32kbps bitrate
        ] as [String : Any]

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
                // print("AudioRecorderManager: Using WAV PCM - 16kHz, mono, 16-bit") // OLD WAV FORMAT
                print("AudioRecorderManager: Using AAC .m4a - 16kHz, mono, 32kbps")
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
            // Use .playAndRecord instead of .record to maintain compatibility with recording
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            print("SpeechRecognizerManager: AVAudioSession set to playAndRecord and activated for speech recognition.")
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
        
        // Check authorization status more carefully
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            print("SpeechRecognizerManager: Speech recognition not authorized. Status: \(authStatus.rawValue)")
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

        // DON'T deactivate the audio session - let the AudioRecorderManager handle it
        // This was causing the "authorization denied" errors for subsequent questions
        /*
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            print("SpeechRecognizerManager: AVAudioSession deactivated.")
        } catch {
            print("SpeechRecognizerManager: Failed to deactivate audio session: \(error.localizedDescription)")
        }
        */
    }

    // MARK: - SFSpeechRecognizerDelegate
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
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
