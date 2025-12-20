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
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(16)
    }
}

struct ExaminerHeader: View {
    let isExaminerSpeaking: Bool

    var body: some View {
        HStack {

            if isExaminerSpeaking {
                // Speaking icon indicator
                HStack(spacing: 6) {
                    Image(systemName: "waveform")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Speaking")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.secondary)
                )
            }

            Spacer()
        }
        .padding(12)
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
                    .font(.callout)
                    .fontWeight(.regular)
                    .multilineTextAlignment(.center)
                    .padding(12)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.32)
    }
}

