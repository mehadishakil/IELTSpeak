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
    var isTimeWarning: Bool = false
    var onCancel: (() -> Void)? = nil

    @State private var isFlipped = false
    @State private var showConfirmation = false
    @State private var warningBlink = false
    private var isActive: Bool { isUserSpeaking || isRecording }
    private let activeBackground = Color(red: 242/255, green: 242/255, blue: 255/255)
    private let activeStroke = Color(red: 180/255, green: 178/255, blue: 240/255)
    private let warningStroke = Color.red.opacity(0.85)
    private let warningGlow = Color.red.opacity(0.35)

    var body: some View {
        ZStack {
            // Front side
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
            .background(isActive ? activeBackground : Color.white)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        isTimeWarning
                            ? (warningBlink ? warningStroke : Color.red.opacity(0.18))
                            : (isActive ? activeStroke : Color.clear),
                        lineWidth: isTimeWarning ? (warningBlink ? 3.5 : 2.0) : 1.5
                    )
            )
            .overlay(
                // Focused warning pulse ring (inward)
                RoundedRectangle(cornerRadius: 32)
                    .strokeBorder(warningGlow, lineWidth: warningBlink ? 8 : 3)
                    .scaleEffect(warningBlink ? 0.965 : 0.99)
                    .blur(radius: warningBlink ? 5 : 2)
                    .opacity(isTimeWarning ? (warningBlink ? 1 : 0) : 0)
                    .allowsHitTesting(false)
            )
            .overlay(
                // Subtle red wash for time warning
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.red.opacity(warningBlink ? 0.10 : 0.03))
                    .allowsHitTesting(false)
                    .opacity(isTimeWarning ? 1 : 0)
            )
            .opacity(isFlipped ? 0 : 1)

            // Back side
            StudentCardBack(onCancel: onCancel, showConfirmation: $showConfirmation)
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
        .onChange(of: showConfirmation) { confirming in
            if !confirming && isFlipped {
                scheduleAutoFlipBack()
            }
        }
        .onChange(of: isTimeWarning) { warning in
            if warning {
                startWarningBlink()
            } else {
                warningBlink = false
            }
        }
        .padding(.horizontal, 16)
    }

    private func startWarningBlink() {
        func blink() {
            guard isTimeWarning else {
                warningBlink = false
                return
            }
            withAnimation(.easeInOut(duration: 0.45)) {
                warningBlink.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                blink()
            }
        }
        blink()
    }

    private func scheduleAutoFlipBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if isFlipped && !showConfirmation {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped = false
                }
            }
        }
    }
}

struct StudentCardBack: View {
    var onCancel: (() -> Void)? = nil
    @Binding var showConfirmation: Bool

    var body: some View {
        ZStack {
            // Main card content
            VStack(spacing: 16) {
                Spacer()

//                Text("End Test")
//                    .font(.headline)
//                    .foregroundColor(.primary)

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showConfirmation = true
                    }
                }) {
                    Text("Cancel Test")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)

                Text("Unfinished tests will not be evaluated.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                Text("Tap to go back")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 16)
            }
            .opacity(showConfirmation ? 0.3 : 1)

            // Inline confirmation overlay
            if showConfirmation {
                VStack(spacing: 12) {
                    Text("Cancel Test?")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Your progress will be lost and this test will not be evaluated.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showConfirmation = false
                            }
                        }) {
                            Text("Cancel")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(12)
                        }

                        Button(action: {
                            onCancel?()
                        }) {
                            Text("Confirm")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.32 + 44)
        .background(Color.white)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1.5)
        )
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
