import SwiftUI

// MARK: - Testing View
struct ExamTestView: View {
    let currentPart: Int
    let currentQuestionText: String
    let isExaminerSpeaking: Bool
    let isUserSpeaking: Bool
    let isRecording: Bool
    let recordingTime: TimeInterval
    let waveformData: [Double]
    let userWaveformData: [Double]
    
    var body: some View {
        VStack(spacing: 0) {
            ExaminerSection(
                currentQuestionText: currentQuestionText,
                isExaminerSpeaking: isExaminerSpeaking,
                waveformData: waveformData
            )
            
            ProgressBarDivider(currentPart: currentPart)
            
            StudentSection(
                isUserSpeaking: isUserSpeaking,
                isRecording: isRecording,
                recordingTime: recordingTime,
                userWaveformData: userWaveformData
            )
        }
    }
}
