import SwiftUI

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
            ProgressBarDivider(currentPart: currentPart)
            
            ExaminerSection(
                currentQuestionText: currentQuestionText,
                isExaminerSpeaking: isExaminerSpeaking,
                waveformData: waveformData
            )
            
            StudentSection(
                isUserSpeaking: isUserSpeaking,
                isRecording: isRecording,
                recordingTime: recordingTime,
                userWaveformData: userWaveformData
            )
        }
    }
}

#Preview {
    ExamTestView(
        currentPart: 1,
        currentQuestionText: "Describe a person who has inspired you. You should say who the person is, how you know them, and why they inspired you.",
        isExaminerSpeaking: true,
        isUserSpeaking: true,
        isRecording: true,
        recordingTime: 12.5,
        waveformData: Array(repeating: 0.6, count: 40),
        userWaveformData: Array(repeating: 0.3, count: 40)
    )
}
