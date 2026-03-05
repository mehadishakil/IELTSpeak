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

    @State private var isFlipped = false
    private let activeBackground = Color(red: 237/255, green: 236/255, blue: 255/255) // #EDECFF
    private let activeStroke = Color(red: 180/255, green: 178/255, blue: 240/255)

    var body: some View {
        ZStack {
            // Front side
            VStack(spacing: 0) {
                ExaminerHeader(isExaminerSpeaking: isExaminerSpeaking)

                ExaminerContent(
                    currentQuestionText: currentQuestionText,
                    isExaminerSpeaking: isExaminerSpeaking,
                    waveformData: waveformData
                )
            }
            .background(isExaminerSpeaking ? activeBackground : Color.white)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(isExaminerSpeaking ? activeStroke : Color.clear, lineWidth: 1.5)
            )
            .opacity(isFlipped ? 0 : 1)

            // Back side
            ExaminerCardBack()
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
            if !isFlipped {
                scheduleAutoFlipBack()
            }
        }
        .onChange(of: isFlipped) { flipped in
            if flipped {
                scheduleAutoFlipBack()
            }
        }
        .padding(16)
    }

    private func scheduleAutoFlipBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if isFlipped {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped = false
                }
            }
        }
    }
}

struct ExaminerCardBack: View {
    @AppStorage("showQuestionsSetting") var showQuestions: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "captions.bubble.fill")
                .font(.system(size: 32))
                .foregroundColor(.blue)

            Text("Question Captions")
                .font(.headline)
                .foregroundColor(.primary)

            Toggle("Show Captions", isOn: $showQuestions)
                .tint(.blue)
                .padding(.horizontal, 32)

            Spacer()

            Text("Tap to go back")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.32 + 44) // Match front card height
        .background(Color.white)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1.5)
        )
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

