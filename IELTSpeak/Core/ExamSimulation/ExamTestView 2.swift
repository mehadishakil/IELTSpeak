//
//  ExamTestView 2.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 23/7/25.
//



//struct ExamTestView: View {
//    let currentPart: Int
//    let currentQuestionText: String
//    let isExaminerSpeaking: Bool
//    let isUserSpeaking: Bool
//    let isRecording: Bool
//    let recordingTime: TimeInterval
//    let waveformData: [Double]
//    let userWaveformData: [Double]
//    let part2PreparationTimeRemaining: TimeInterval
//    let part2SpeakingTimeRemaining: TimeInterval
//
//    var formattedRecordingTime: String {
//        let minutes = Int(recordingTime) / 60
//        let seconds = Int(recordingTime) % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Spacer()
//
//            if currentPart == 2 && part2PreparationTimeRemaining > 0 {
//                VStack {
//                    Text("Preparation Time Remaining:")
//                        .font(.headline)
//                    Text(String(format: "%02d:%02d", Int(part2PreparationTimeRemaining) / 60, Int(part2PreparationTimeRemaining) % 60))
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.accentColor)
//                    ProgressView(value: 60 - part2PreparationTimeRemaining, total: 60)
//                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
//                        .padding(.horizontal)
//                }
//                .transition(.opacity)
//            } else if currentPart == 2 && part2SpeakingTimeRemaining > 0 {
//                VStack {
//                    Text("Speaking Time Remaining (Max 2:00):")
//                        .font(.headline)
//                    Text(String(format: "%02d:%02d", Int(part2SpeakingTimeRemaining) / 60, Int(part2SpeakingTimeRemaining) % 60))
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(part2SpeakingTimeRemaining <= 30 ? .red : .accentColor)
//                    ProgressView(value: 120 - part2SpeakingTimeRemaining, total: 120)
//                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
//                        .padding(.horizontal)
//                }
//                .transition(.opacity)
//            }
//
//
//            Text("Examiner's Question:")
//                .font(.headline)
//                .foregroundColor(.secondary)
//
//            Text(currentQuestionText)
//                .font(.title2)
//                .fontWeight(.medium)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal)
//                .frame(minHeight: 80) // Give it a fixed minimum height to prevent jumpiness
//
//            if isExaminerSpeaking {
//                WaveformView(amplitudes: waveformData, color: .blue)
//                    .frame(height: 50)
//                    .padding(.horizontal)
//                    .transition(.opacity)
//            } else {
//                Text("Waiting for your response...")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .opacity(isRecording ? 0 : 1) // Hide if recording starts
//                    .transition(.opacity)
//            }
//
//            Spacer()
//
//            if isRecording {
//                VStack {
//                    Text("Your Response:")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                    Text(formattedRecordingTime)
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(.green)
//                    WaveformView(amplitudes: userWaveformData, color: .green)
//                        .frame(height: 50)
//                        .padding(.horizontal)
//                }
//                .transition(.opacity) // Animate appearance
//            } else {
//                Image(systemName: "mic.fill")
//                    .font(.largeTitle)
//                    .foregroundColor(.gray.opacity(0.5))
//                    .frame(height: 50)
//                    .padding(.horizontal)
//            }
//
//            Spacer()
//        }
//    }
//}

