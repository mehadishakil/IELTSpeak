//
//  WordPronunciation.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 10/8/25.
//


import SwiftUI
import AVFoundation

// MARK: - Models
struct WordPronunciation: Identifiable {
    let id = UUID()
    let word: String
    let ipa: String
    let audioURL: URL?
    var score: Int? // 0-100 or nil if not yet practiced
}

// MARK: - Audio Manager (simple local player + stub recorder)
final class PronunciationAudioManager: ObservableObject {
    static let shared = PronunciationAudioManager()
    private var player: AVAudioPlayer?

    func play(url: URL?, slow: Bool = false) {
        guard let url = url else {
            // In preview or missing file, just simulate play
            print("🔊 play simulated for missing URL")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.enableRate = true
            player?.rate = slow ? 0.7 : 1.0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Audio play error:", error)
        }
    }

    // Stubbed recording function that "evaluates" pronunciation and returns a random score.
    // Replace with real recorder + pronunciation API integration (Azure, Google, etc.)
    func recordAndEvaluate(completion: @escaping (Int) -> Void) {
        // simulate delay and random score
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let randomScore = Int.random(in: 55...98)
            completion(randomScore)
        }
    }
}

// MARK: - Views
struct PronunciationLessonView: View {
    @State private var words: [WordPronunciation]
    @State private var slowMode = false
    @State private var showRecordHUD = false
    @State private var practicingWord: WordPronunciation?

    init(words: [WordPronunciation]) {
        _words = State(initialValue: words)
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            lessonSentence

            List {
                ForEach(words.indices, id: \.self) { idx in
                    WordRow(wordModel: $words[idx], slowMode: $slowMode, onPractice: { practiced in
                        // update score for the practiced word
                        if let i = words.firstIndex(where: { $0.id == practiced.id }) {
                            words[i].score = practiced.score
                        }
                    })
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)

            Spacer()

            bottomBar
        }
        .padding()
        .navigationTitle("Pronunciation Practice")
        .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button(action: { toggleSlowMode() }) { Image(systemName: slowMode ? "tortoise.fill" : "tortoise") } } }
        .overlay(recordingHUD, alignment: .center)
    }

    // MARK: - Subviews
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Lesson: Talking about the environment")
                    .font(.headline)
                Text("Focus: stress, intonation, and individual sounds")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ProgressView(value: averageScoreDouble, total: 100)
                .frame(width: 120)
        }
    }

    private var lessonSentence: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("The climate is changing rapidly.")
                    .font(.title3)
                Spacer()
                Button(action: { playAll() }) {
                    Label("Play All", systemImage: "play.circle")
                }
            }
            Toggle(isOn: $slowMode) {
                Label("Slow Mode", systemImage: "tortoise")
            }
            .toggleStyle(SwitchToggleStyle())
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button(action: { bookmarkProblems() }) {
                Label("Bookmark Problems", systemImage: "bookmark")
            }
            Spacer()
            Button(action: { practiceAll() }) {
                Text("Practice All (Shadowing)")
                    .bold()
            }
            .buttonStyle(DefaultButtonStyle())
            .background(Color.accentColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }

    private var recordingHUD: some View {
        Group {
            if showRecordHUD, let practicingWord = practicingWord {
                VStack(spacing: 12) {
                    Text("Listening…")
                        .font(.headline)
                    Text(practicingWord.word)
                        .font(.title)
                        .bold()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                .padding(20)
                .background(Color(.systemBackground).opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 8)
            }
        }
    }

    // MARK: - Actions
    private var averageScoreDouble: Double {
        let scored = words.compactMap { $0.score }
        guard !scored.isEmpty else { return 0 }
        return Double(scored.reduce(0, +)) / Double(scored.count)
    }

    private func toggleSlowMode() {
        slowMode.toggle()
    }

    private func playAll() {
        Task {
            for word in words {
                PronunciationAudioManager.shared.play(url: word.audioURL, slow: slowMode)
                try? await Task.sleep(nanoseconds: 350_000_000) // small gap between words
            }
        }
    }

    private func practiceAll() {
        Task {
            for idx in words.indices {
                practicingWord = words[idx]
                showRecordHUD = true
                // UI updates already happen on main queue via DispatchQueue.main.async
                PronunciationAudioManager.shared.recordAndEvaluate { score in
                    DispatchQueue.main.async {
                        words[idx].score = score
                        showRecordHUD = false
                        practicingWord = nil
                    }
                }
                // wait a bit before next word so UI updates in preview
                try? await Task.sleep(nanoseconds: 1_400_000_000)
            }
        }
    }

    private func bookmarkProblems() {
        // For demo: print words with low score
        let problems = words.filter { ($0.score ?? 100) < 80 }
        print("Bookmarked problems:", problems.map { $0.word })
    }
}

// MARK: - Word Row
struct WordRow: View {
    @Binding var wordModel: WordPronunciation
    @Binding var slowMode: Bool
    var onPractice: (WordPronunciation) -> Void

    @State private var isPlaying = false
    @State private var showMouthHint = false
    @State private var evaluating = false

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(wordModel.word)
                        .font(.headline)
                    Text(wordModel.ipa)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)

                    if let score = wordModel.score {
                        PronunciationScorePill(score: score)
                    }

                    Spacer()

                    Button(action: { play() }) {
                        Image(systemName: "speaker.wave.2")
                    }
                    .buttonStyle(.plain)

                    Button(action: { withAnimation { showMouthHint.toggle() } }) {
                        Image(systemName: "mouth")
                    }
                    .buttonStyle(.plain)
                }

                if showMouthHint {
                    HStack(spacing: 12) {
                        Image(systemName: "person.crop.square")
                            .font(.largeTitle)
                        VStack(alignment: .leading) {
                            Text("Mouth tip: Keep your tongue behind the teeth for /θ/ sound.")
                                .font(.caption)
                            Text("Example: think, thought")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

            }
        }
        .padding(.vertical, 8)
    }

    private func play() {
        isPlaying = true
        PronunciationAudioManager.shared.play(url: wordModel.audioURL, slow: slowMode)
        DispatchQueue.main.asyncAfter(deadline: .now() + (slowMode ? 1.8 : 1.0)) {
            isPlaying = false
        }
    }

    private func practice() {
        evaluating = true
        PronunciationAudioManager.shared.recordAndEvaluate { score in
            var updated = wordModel
            updated.score = score
            DispatchQueue.main.async {
                wordModel.score = score
                onPractice(updated)
                evaluating = false
            }
        }
    }
}

// MARK: - Score Pill
struct PronunciationScorePill: View {
    let score: Int

    var body: some View {
        Text("\(score)%")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor(for: score))
            .foregroundColor(.white)
            .cornerRadius(8)
    }

    private func backgroundColor(for score: Int) -> Color {
        switch score {
        case 85...100: return .green
        case 70..<85: return .yellow
        default: return .red
        }
    }
}

// MARK: - Preview
struct PronunciationLessonView_Previews: PreviewProvider {
    static var sampleWords: [WordPronunciation] {
        [
            WordPronunciation(word: "Climate", ipa: "[ˈklaɪ.mət]", audioURL: nil, score: 96),
            WordPronunciation(word: "Changing", ipa: "[ˈtʃeɪn.dʒɪŋ]", audioURL: nil, score: 82),
            WordPronunciation(word: "Rapidly", ipa: "[ˈræp.ɪd.li]", audioURL: nil, score: 64),
            WordPronunciation(word: "Environment", ipa: "[ɪnˈvaɪ.rən.mənt]", audioURL: nil, score: nil)
        ]
    }

    static var previews: some View {
        NavigationView {
            PronunciationLessonView(words: sampleWords)
        }
    }
}
