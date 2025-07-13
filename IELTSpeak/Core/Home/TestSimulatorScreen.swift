import SwiftUI

struct TestSimulatorScreen: View {
    @State private var currentPhase: TestPhase = .preparation
    @State private var currentPart: Int = 1
    @State private var currentQuestion: Int = 0
    @State private var isRecording: Bool = false
    @State private var showWaveform: Bool = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var waveformData: [Double] = Array(repeating: 0.0, count: 50)
    @State private var showQuestions: Bool = true
    @State private var isProcessing: Bool = false
    @State private var showResults: Bool = false
    @State private var isUserSpeaking: Bool = false
    @State private var userWaveformData: [Double] = Array(repeating: 0.0, count: 30)
    @State private var isExaminerSpeaking: Bool = false
    @Environment(\.dismiss) private var dismiss
    let questions: [[QuestionItem]]
    
    let testQuestions: [TestPart] = [
        TestPart(
            part: 1,
            title: "Introduction & Interview",
            duration: "4-5 minutes",
            questions: [
                "What's your full name?",
                "Where are you from?",
                "Do you work or study?",
                "Tell me about your hometown.",
                "What do you like most about your job/studies?"
            ]
        ),
        TestPart(
            part: 2,
            title: "Individual Long Turn",
            duration: "2-3 minutes",
            questions: [
                "Describe a memorable journey you have taken. You should say:\n• Where you went\n• Who you went with\n• What you did there\n• And explain why it was memorable"
            ]
        ),
        TestPart(
            part: 3,
            title: "Two-way Discussion",
            duration: "4-5 minutes",
            questions: [
                "How has travel changed in your country over the past decades?",
                "What are the benefits of traveling to different countries?",
                "Do you think virtual reality will replace real travel in the future?",
                "How important is it for young people to travel?"
            ]
        )
    ]
    
    var currentTestPart: TestPart {
        testQuestions[currentPart - 1]
    }
    
    var currentQuestionText: String {
        guard currentQuestion < currentTestPart.questions.count else { return "" }
        return currentTestPart.questions[currentQuestion]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 0) {
                    // Header
                    headerSection
                    
                    // Content based on phase
                    switch currentPhase {
                    case .preparation:
                        preparationView
                    case .testing:
                        testingView
                    case .processing:
                        processingView
                    case .completed:
                        completedView
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                generateWaveformData()
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            // Header content
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack {
                    // Close button
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    // Title
                    VStack(spacing: 2) {
                        Text("IELTS Speaking Test")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if currentPhase == .testing {
                            Text("Part \(currentPart) of 3")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(height: 80)
        }
    }
    
    private var preparationView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Test overview
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
                
                // Question display setting
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
                
                // Test parts overview
                VStack(spacing: 12) {
                    ForEach(testQuestions, id: \.part) { part in
                        TestPartCard(testPart: part)
                    }
                }
                .padding(.horizontal, 20)
                
                // Start button
                Button(action: startTest) {
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
            .padding(.top, 30)
        }
    }
    
    private var testingView: some View {
        VStack(spacing: 0) {
            // EXAMINER SECTION (Top Half)
            examinerSection
            
            // Progress Bar Divider
            progressBarDivider
            
            // STUDENT SECTION (Bottom Half)
            studentSection
        }
    }
    
    private var examinerSection: some View {
        VStack(spacing: 0) {
            // Examiner header
            HStack {
                Spacer()
                
                // Examiner status
                if isExaminerSpeaking {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isExaminerSpeaking)
                        
                        Text("Speaking")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            
            // Examiner content area
            VStack {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .scaleEffect(isExaminerSpeaking ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isExaminerSpeaking)
                    
                    Image(systemName: "person.wave.2.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                Text("Examiner")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                // Question display
                Text(currentQuestionText)
                    .font(.body)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(12)
                
                // Examiner waveform
                if isExaminerSpeaking {
                    VStack(spacing: 8) {
                        HStack(spacing: 3) {
                            ForEach(0..<min(waveformData.count, 25), id: \.self) { index in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.blue.opacity(0.6))
                                    .frame(width: 3, height: CGFloat(waveformData[index] * 25 + 5))
                                    .animation(.easeInOut(duration: 0.1), value: waveformData[index])
                            }
                        }
                        .frame(height: 30)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .background(Color(.systemGray6))
        }
    }
    
    private var progressBarDivider: some View {
        VStack(spacing: 0) {
            // Progress bar
            HStack(spacing: 0) {
                ForEach(1...3, id: \.self) { partNumber in
                    Rectangle()
                        .fill(partNumber <= currentPart ?
                              LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                              ) :
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gray.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .frame(height: 4)
                    
                    if partNumber < 3 {
                        Rectangle()
                            .fill(Color(.systemBackground))
                            .frame(width: 2, height: 4)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            
            // Part labels
            HStack {
                ForEach(1...3, id: \.self) { partNumber in
                    VStack(spacing: 2) {
                        Text("Part \(partNumber)")
                            .font(.caption)
                            .fontWeight(partNumber == currentPart ? .semibold : .medium)
                            .foregroundColor(partNumber <= currentPart ? .blue : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
    
    private var studentSection: some View {
        VStack(spacing: 0) {
            // Student header
            HStack {
                Spacer()
                
                // Recording timer
                if isRecording {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isRecording)
                        
                        Text(timeString(from: recordingTime))
                            .font(.caption)
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            
            // Student content area
            VStack {
                
                // Examiner status
                if isUserSpeaking || isRecording {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.2)
                            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isExaminerSpeaking)
                        
                        Text("Speaking")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isUserSpeaking ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isUserSpeaking)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
                .padding(.top, 20)
                
                Text("You")
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                // User waveform
                if isUserSpeaking || isRecording {
                    HStack(spacing: 2) {
                        ForEach(0..<userWaveformData.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.green.opacity(0.7))
                                .frame(width: 4, height: CGFloat(userWaveformData[index] * 30 + 6))
                                .animation(.easeInOut(duration: 0.1), value: userWaveformData[index])
                        }
                    }
                    .frame(height: 40)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .background(Color(.systemBackground))
        }
        .onAppear {
            if currentPhase == .testing {
                startConversationFlow()
            }
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 30) {
            // Processing animation
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.blue, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .rotationEffect(.degrees(isProcessing ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isProcessing)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                
                Text("Processing Your Test")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Our AI is analyzing your responses and preparing detailed feedback...")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Processing steps
            VStack(spacing: 16) {
                ProcessingStep(title: "Analyzing Speech Quality", isCompleted: true)
                ProcessingStep(title: "Evaluating Fluency & Coherence", isCompleted: true)
                ProcessingStep(title: "Checking Grammar & Vocabulary", isCompleted: false)
                ProcessingStep(title: "Generating Feedback", isCompleted: false)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 50)
        .onAppear {
            isProcessing = true
            // Simulate processing time
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                currentPhase = .completed
                isProcessing = false
            }
        }
    }
    
    private var completedView: some View {
        VStack(spacing: 30) {
            // Success animation
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                Text("Test Completed!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Your test has been successfully processed. You can now view your detailed feedback and scores.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Results button
            Button(action: {
                dismiss()
                // Navigate to results would be handled by parent view
            }) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                    
                    Text("View Results")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.top, 50)
    }
    
    // MARK: - Helper Methods
    
    private func startTest() {
        currentPhase = .testing
        showWaveform = true
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        isUserSpeaking = isRecording
        
        if isRecording {
            startTimer()
            generateUserWaveform()
        } else {
            stopTimer()
        }
    }
    
    private func nextQuestion() {
        if currentQuestion < currentTestPart.questions.count - 1 {
            currentQuestion += 1
            startConversationFlow()
        } else if currentPart < 3 {
            currentPart += 1
            currentQuestion = 0
            startConversationFlow()
        } else {
            // Test completed
            currentPhase = .processing
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            recordingTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func generateWaveformData() {
        if isExaminerSpeaking {
            for i in 0..<waveformData.count {
                waveformData[i] = Double.random(in: 0.1...1.0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generateWaveformData()
            }
        }
    }
    
    private func startConversationFlow() {
        // Reset states
        isUserSpeaking = false
        isRecording = false
        isExaminerSpeaking = true
        
        // Simulate AI asking question
        generateWaveformData()
        
        // After 3 seconds, AI stops speaking
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isExaminerSpeaking = false
        }
    }
    
    private func generateUserWaveform() {
        if isUserSpeaking && isRecording {
            for i in 0..<userWaveformData.count {
                userWaveformData[i] = Double.random(in: 0.2...1.0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                generateUserWaveform()
            }
        }
    }
}


struct ProcessingStep: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .gray)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct TestSimulatorScreen_Previews: PreviewProvider {
    static var previews: some View {
        // TestSimulatorScreen(questions: <#[[QuestionItem]]#>)
    }
}
