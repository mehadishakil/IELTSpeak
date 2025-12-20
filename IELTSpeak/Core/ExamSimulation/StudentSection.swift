//
//  StudentHeader.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.


import SwiftUI


struct StudentSection: View {
    let isUserSpeaking: Bool
    let isRecording: Bool
    let recordingTime: TimeInterval
    let userWaveformData: [Double]

    var body: some View {
        VStack(spacing: 0) {
            StudentHeader(
                isRecording: isRecording,
                recordingTime: recordingTime,
                isUserSpeaking: isUserSpeaking
            )

            StudentContent(
                isUserSpeaking: isUserSpeaking,
                isRecording: isRecording,
                waveformData: userWaveformData
            )
        }
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

struct StudentHeader: View {
    let isRecording: Bool
    let recordingTime: TimeInterval
    let isUserSpeaking: Bool

    var body: some View {
        HStack {

            if isUserSpeaking || isRecording {
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

            if isRecording {
                RecordingTimer(recordingTime: recordingTime)
            }
        }
        .padding(12)
    }
}

struct StudentContent: View {
    let isUserSpeaking: Bool
    let isRecording: Bool
    let waveformData: [Double]

    var body: some View {
        VStack {
            AIAvatarView(isActive: isUserSpeaking, color: .green, icon: "person.fill")

            Text("You")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            if isUserSpeaking || isRecording {
                WaveformView(data: waveformData, color: .blue)
                    .frame(height: 50)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.32)
    }
}
