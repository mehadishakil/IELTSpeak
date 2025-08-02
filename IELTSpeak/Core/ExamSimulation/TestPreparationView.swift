////
////  TestPreparationView.swift
////  IELTSpeak
////
////  Created by Mehadi Hasan on 17/7/25.
////
//
//import SwiftUI
//import AVFoundation
//
//struct TestPreparationView: View {
//    let onStartTest: () -> Void
//    @State private var showMicDeniedAlert = false
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 30) {
//                PreparationHeaderSection()
//                
//                QuestionDisplayToggle()
//                
//                TestPartsOverview()
//                
//                StartTestButton(
//                    onStartTest: onStartTest,
//                    showMicDeniedAlert: $showMicDeniedAlert
//                )
//            }
//            .padding(.top, 30)
//        }
//        .alert("Microphone Access Required", isPresented: $showMicDeniedAlert) {
//            Button("OK", role: .cancel) {}
//            Button("Open Settings") {
//                openAppSettings()
//            }
//        } message: {
//            Text("Please enable microphone access in Settings to start the test.")
//        }
//    }
//
//    private func openAppSettings() {
//        if let url = URL(string: UIApplication.openSettingsURLString) {
//            UIApplication.shared.open(url)
//        }
//    }
//}
//
//// MARK: - Preparation Components
//struct PreparationHeaderSection: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "mic.circle.fill")
//                .font(.system(size: 80))
//                .foregroundColor(.blue)
//            
//            Text("Ready to Begin?")
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(.primary)
//            
//            Text("This test simulates the real IELTS Speaking test experience with 3 parts.")
//                .font(.body)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 20)
//        }
//    }
//}
//
//import SwiftUI
//
//struct QuestionDisplayToggle: View {
//    @AppStorage("showQuestionsSetting") var showQuestions: Bool = true
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Show Questions During Test")
//                        .font(.system(.headline, weight: .semibold))
//
//                    Text("You can choose to see or hide the questions while taking the test.")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//
//                Spacer()
//
//                Toggle("", isOn: $showQuestions)
//                    .labelsHidden()
//                    .tint(.blue)
//            }
//
//            HStack(spacing: 8) {
//                Image(systemName: showQuestions ? "eye.fill" : "eye.slash.fill")
//                    .foregroundColor(showQuestions ? .blue : .gray)
//
//                Text(showQuestions ? "Questions will be displayed on screen." : "Questions will be hidden. Listen carefully.")
//                    .font(.footnote)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 16, style: .continuous)
//                .fill(Color(.systemGray6))
//        )
//        .padding(.horizontal)
//    }
//}
//
//
//struct TestPartsOverview: View {
//    var body: some View {
//        VStack(spacing: 12) {
//            ForEach(testQuestions, id: \.part) { part in
//                TestPartCard(testPart: part)
//            }
//        }
//        .padding(.horizontal, 20)
//    }
//}
//
//struct StartTestButton: View {
//    let onStartTest: () -> Void
//    @Binding var showMicDeniedAlert: Bool
//
//    var body: some View {
//        Button(action: handleStartTest) {
//            HStack {
//                Image(systemName: "play.fill")
//                    .font(.title2)
//
//                Text("Start Test")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//            }
//            .foregroundColor(.white)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 16)
//            .background(
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.blue, Color.purple]),
//                    startPoint: .leading,
//                    endPoint: .trailing
//                )
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//        }
//        .padding(.horizontal, 20)
//        .padding(.bottom, 30)
//    }
//
//    private func handleStartTest() {
//        switch AVAudioSession.sharedInstance().recordPermission {
//        case .granted:
//            onStartTest()
//        case .denied:
//            showMicDeniedAlert = true
//        case .undetermined:
//            AVAudioSession.sharedInstance().requestRecordPermission { granted in
//                DispatchQueue.main.async {
//                    if granted {
//                        onStartTest()
//                    } else {
//                        showMicDeniedAlert = true
//                    }
//                }
//            }
//        @unknown default:
//            showMicDeniedAlert = true
//        }
//    }
//}
//
//#Preview(body: {
//    TestPreparationView(){
//        
//    }
//})


//
//  TestPreparationView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI
import AVFoundation

struct TestPreparationView: View {
    let onStartTest: () -> Void
    @State private var showMicDeniedAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                PreparationHeaderSection()
                
                QuestionDisplayToggle()
                
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
            
            Text("This test simulates the real IELTS Speaking test experience with 3 parts. Your responses will be analyzed by AI for detailed feedback.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
}

struct QuestionDisplayToggle: View {
    @AppStorage("showQuestionsSetting") var showQuestions: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Show Questions During Test")
                        .font(.system(.headline, weight: .semibold))

                    Text("You can choose to see or hide the questions while taking the test.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Toggle("", isOn: $showQuestions)
                    .labelsHidden()
                    .tint(.blue)
            }

            HStack(spacing: 8) {
                Image(systemName: showQuestions ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(showQuestions ? .blue : .gray)

                Text(showQuestions ? "Questions will be displayed on screen." : "Questions will be hidden. Listen carefully.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
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

                Text("Start AI-Powered Test")
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
    TestPreparationView(){
        
    }
})
