//
//  ExaminerSection.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

struct ExaminerSection: View {
    let currentQuestionText: String
    let isExaminerSpeaking: Bool
    let waveformData: [Double]
    
    var body: some View {
        VStack(spacing: 0) {
            ExaminerHeader(isExaminerSpeaking: isExaminerSpeaking)
            
            ExaminerContent(
                currentQuestionText: currentQuestionText,
                isExaminerSpeaking: isExaminerSpeaking,
                waveformData: waveformData
            )
        }
    }
}

struct ExaminerHeader: View {
    let isExaminerSpeaking: Bool
    
    var body: some View {
        HStack {
            Spacer()
            
            if isExaminerSpeaking {
                SpeakingIndicator(color: .blue, text: "Speaking")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }
}

struct ExaminerContent: View {
    let currentQuestionText: String
    let isExaminerSpeaking: Bool
    let waveformData: [Double]
    @AppStorage("showQuestionsSetting") var showQuestions: Bool = true
    
    var body: some View {
        VStack {
            AIAvatarView(isActive: isExaminerSpeaking, color: .blue, icon: "person.wave.2.fill")
            
            Text("Examiner")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            if showQuestions {
                Text(currentQuestionText)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(12)
            }
            
            if isExaminerSpeaking {
                WaveformView(amplitudes: waveformData, color: .blue)
                    .frame(height: 50)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .background(Color(.systemGray6))
    }
}
