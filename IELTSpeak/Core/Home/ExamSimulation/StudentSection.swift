//
//  StudentHeader.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI


struct StudentSection: View {
    let isUserSpeaking: Bool
    let isRecording: Bool
    let recordingTime: TimeInterval
    let userWaveformData: [Double]
    
    var body: some View {
        VStack(spacing: 0) {
            StudentHeader(isRecording: isRecording, recordingTime: recordingTime)
            
            StudentContent(
                isUserSpeaking: isUserSpeaking,
                isRecording: isRecording,
                userWaveformData: userWaveformData
            )
        }
    }
}

struct StudentHeader: View {
    let isRecording: Bool
    let recordingTime: TimeInterval
    
    var body: some View {
        HStack {
            Spacer()
            
            if isRecording {
                RecordingTimer(recordingTime: recordingTime)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

struct StudentContent: View {
    let isUserSpeaking: Bool
    let isRecording: Bool
    let userWaveformData: [Double]
    
    var body: some View {
        VStack {
            if isUserSpeaking || isRecording {
                SpeakingIndicator(color: .blue, text: "Speaking")
            }
            
            AIAvatarView(isActive: isUserSpeaking, color: .green, icon: "person.fill")
            
            Text("You")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            if isUserSpeaking || isRecording {
//                WaveformView(amplitudes: waveformData, color: .blue)
//                    .frame(height: 50)
//                    .padding(.horizontal)
//                    .transition(.opacity)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .background(Color(.systemBackground))
    }
}
