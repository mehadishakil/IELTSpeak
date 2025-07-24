//
//  TestPreparationView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI
import AVFoundation

struct TestPreparationView: View {
    @Binding var showQuestions: Bool
    let onStartTest: () -> Void
    @State private var showMicDeniedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                PreparationHeaderSection()
                
                QuestionDisplayToggle(showQuestions: $showQuestions)
                
                TestPartsOverview()
                
                StartTestButton(
                    onStartTest: onStartTest,
                    showMicDeniedAlert: $showMicDeniedAlert
                )
            }
            .padding(.top, 30)
        }
        .alert("Microphone Access Required", isPresented: $showMicDeniedAlert) {
            Button("OK", role: .cancel) {}
            Button("Open Settings") {
                openAppSettings()
            }
        } message: {
            Text("Please enable microphone access in Settings to start the test.")
        }
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Preparation Components
struct PreparationHeaderSection: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Ready to Begin?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("This test simulates the real IELTS Speaking test experience with 3 parts.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

struct QuestionDisplayToggle: View {
    @Binding var showQuestions: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Display Questions During Test")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $showQuestions)
                    .labelsHidden()
            }
            .padding(.horizontal, 20)
            
            Text(showQuestions ? "Questions will be shown on screen during the test" : "Questions will be hidden - listen carefully to the examiner")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 20)
    }
}

struct TestPartsOverview: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(testQuestions, id: \.part) { part in
                TestPartCard(testPart: part)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct StartTestButton: View {
    let onStartTest: () -> Void
    @Binding var showMicDeniedAlert: Bool

    var body: some View {
        Button(action: handleStartTest) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.title2)

                Text("Start Test")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    private func handleStartTest() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            onStartTest()
        case .denied:
            showMicDeniedAlert = true
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        onStartTest()
                    } else {
                        showMicDeniedAlert = true
                    }
                }
            }
        @unknown default:
            showMicDeniedAlert = true
        }
    }
}

#Preview(body: {
    TestPreparationView(showQuestions: .constant(true)){
        
    }
})
