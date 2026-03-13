//
//  OnboardingView.swift
//  IELTSpeak
//
//  Created by Claude on 3/7/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentStep = 0
    @State private var targetBandRange: String? = nil
    @State private var currentLevel: String? = nil
    @State private var purpose: String? = nil
    @State private var dailyGoal: String? = nil

    private let totalSteps = 6

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar (hidden on first and last step)
                if currentStep > 0 && currentStep < totalSteps - 1 {
                    OnboardingProgressBar(
                        current: currentStep,
                        total: totalSteps - 1,
                        onBack: { withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { currentStep -= 1 } }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                // Content
                TabView(selection: $currentStep) {
                    WelcomeStep(onContinue: nextStep)
                        .tag(0)

                    TargetBandStep(selectedRange: $targetBandRange, onContinue: nextStep)
                        .tag(1)

                    CurrentLevelStep(selectedLevel: $currentLevel, onContinue: nextStep)
                        .tag(2)

                    PurposeStep(selectedPurpose: $purpose, onContinue: nextStep)
                        .tag(3)

                    DailyGoalStep(selectedGoal: $dailyGoal, onContinue: nextStep)
                        .tag(4)

                    ReadyStep(targetBandRange: targetBandRange ?? "7.0-8.0", onGetStarted: completeOnboarding)
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentStep)
            }
        }
    }

    private func nextStep() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentStep = min(currentStep + 1, totalSteps - 1)
        }
    }

    private func completeOnboarding() {
        // Save user preferences
        if let goal = dailyGoal {
            UserDefaults.standard.set(goal, forKey: "dailyPracticeGoal")
        }
        if let level = currentLevel {
            UserDefaults.standard.set(level, forKey: "currentLevel")
        }
        if let purpose = purpose {
            UserDefaults.standard.set(purpose, forKey: "learningPurpose")
        }
        if let range = targetBandRange {
            UserDefaults.standard.set(range, forKey: "targetBandRange")
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Progress Bar
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.brandGreen, Color.primaryVariant],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(current) / CGFloat(total), height: 10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: current)
                }
            }
            .frame(height: 10)
        }
    }
}

// MARK: - Green CTA Button
struct OnboardingButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.custom("Fredoka-Bold", size: 16))
                .tracking(1.2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled
                              ? LinearGradient(colors: [Color.brandGreen, Color.primaryVariant], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .leading, endPoint: .trailing)
                        )
                        .shadow(color: isEnabled ? Color.primaryVariant.opacity(0.4) : .clear, radius: 10, y: 4)
                )
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 24)
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStep: View {
    let onContinue: () -> Void
    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.1))
                    .frame(width: 140, height: 140)
                    .scaleEffect(appear ? 1.0 : 0.6)

                Circle()
                    .fill(Color.brandGreen.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(appear ? 1.0 : 0.7)

                Image(systemName: "mic.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.brandGreen)
                    .scaleEffect(appear ? 1.0 : 0.5)
            }
            .padding(.bottom, 40)

            Text("Ace Your IELTS\nSpeaking Test")
                .font(.custom("Fredoka-Bold", size: 32))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            Text("Practice with AI-powered mock tests,\nget instant feedback, and track your\nprogress to your target band score.")
                .font(.custom("Fredoka-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .padding(.top, 16)
                .padding(.horizontal, 32)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            // Feature pills
            HStack(spacing: 12) {
                FeaturePill(icon: "waveform", text: "AI Scoring")
                FeaturePill(icon: "clock", text: "15 min Tests")
                FeaturePill(icon: "chart.line.uptrend.xyaxis", text: "Track Progress")
            }
            .padding(.top, 28)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)

            Spacer()
            Spacer()

            OnboardingButton("Get Started", action: onContinue)
                .opacity(appear ? 1 : 0)
                .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appear = true
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.custom("Fredoka-Medium", size: 12))
        }
        .foregroundColor(.brandGreen)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.brandGreen.opacity(0.1))
        )
    }
}

// MARK: - Step 2: Target Band
struct TargetBandStep: View {
    @Binding var selectedRange: String?
    let onContinue: () -> Void

    private let ranges: [(id: String, label: String, description: String, icon: String)] = [
        ("5.0-6.0", "Band 5.0 – 6.0", "Building foundations", "leaf.fill"),
        ("6.0-7.0", "Band 6.0 – 7.0", "Competent speaker", "flame.fill"),
        ("7.0-8.0", "Band 7.0 – 8.0", "Fluent & confident", "bolt.fill"),
        ("8.0-9.0", "Band 8.0 – 9.0", "Near-native mastery", "star.fill")
    ]

    private func rangeColor(for id: String) -> Color {
        switch id {
        case "8.0-9.0": return Color(red: 76/255, green: 175/255, blue: 80/255)
        case "7.0-8.0": return Color(red: 66/255, green: 165/255, blue: 245/255)
        case "6.0-7.0": return .warningOrange
        default: return .errorRed
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.1))
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(Color.brandGreen.opacity(0.2))
                    .frame(width: 76, height: 76)

                Image(systemName: "target")
                    .font(.system(size: 34))
                    .foregroundColor(.brandGreen)
            }
            .padding(.bottom, 28)

            Text("What's your target\nband score?")
                .font(.custom("Fredoka-Bold", size: 28))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text("We'll personalize your practice plan")
                .font(.custom("Fredoka-Regular", size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 28)

            // Range cards
            VStack(spacing: 12) {
                ForEach(ranges, id: \.id) { range in
                    let isSelected = selectedRange == range.id
                    let color = rangeColor(for: range.id)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedRange = range.id
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? color.opacity(0.15) : Color(.systemGray6))
                                    .frame(width: 44, height: 44)

                                Image(systemName: range.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(isSelected ? color : .secondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(range.label)
                                    .font(.custom("Fredoka-SemiBold", size: 16))
                                    .foregroundColor(.primary)

                                Text(range.description)
                                    .font(.custom("Fredoka-Regular", size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(color)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isSelected ? color : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            OnboardingButton("Continue", isEnabled: selectedRange != nil, action: onContinue)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Step 3: Current Level
struct CurrentLevelStep: View {
    @Binding var selectedLevel: String?
    let onContinue: () -> Void

    private let levels: [(id: String, title: String, subtitle: String, icon: String, band: String)] = [
        ("beginner", "Beginner", "I struggle with basic conversations", "leaf.fill", "Band 4-5"),
        ("intermediate", "Intermediate", "I can communicate but make errors", "flame.fill", "Band 5.5-6.5"),
        ("advanced", "Advanced", "I speak fluently with minor mistakes", "bolt.fill", "Band 7-8"),
        ("expert", "Near Expert", "I just need to polish my skills", "star.fill", "Band 8-9")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("What's your current\nspeaking level?")
                .font(.custom("Fredoka-Bold", size: 28))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text("Be honest — it helps us help you!")
                .font(.custom("Fredoka-Regular", size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 28)

            VStack(spacing: 12) {
                ForEach(levels, id: \.id) { level in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedLevel = level.id
                        }
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedLevel == level.id ? Color.brandGreen.opacity(0.15) : Color(.systemGray6))
                                    .frame(width: 44, height: 44)

                                Image(systemName: level.icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(selectedLevel == level.id ? .brandGreen : .secondary)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(level.title)
                                    .font(.custom("Fredoka-SemiBold", size: 16))
                                    .foregroundColor(.primary)

                                Text(level.subtitle)
                                    .font(.custom("Fredoka-Regular", size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Text(level.band)
                                .font(.custom("Fredoka-Medium", size: 12))
                                .foregroundColor(selectedLevel == level.id ? .brandGreen : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(selectedLevel == level.id ? Color.brandGreen.opacity(0.1) : Color(.systemGray6))
                                )
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedLevel == level.id ? Color.brandGreen : Color(.systemGray4), lineWidth: selectedLevel == level.id ? 2 : 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            OnboardingButton("Continue", isEnabled: selectedLevel != nil, action: onContinue)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Step 4: Purpose
struct PurposeStep: View {
    @Binding var selectedPurpose: String?
    let onContinue: () -> Void

    private let purposes: [(id: String, title: String, icon: String)] = [
        ("academic", "University Admission", "graduationcap.fill"),
        ("immigration", "Immigration / Visa", "airplane"),
        ("career", "Career & Job", "briefcase.fill"),
        ("scholarship", "Scholarship", "medal.fill"),
        ("personal", "Personal Goal", "target"),
        ("other", "Other", "ellipsis.circle.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Why are you\npreparing for IELTS?")
                .font(.custom("Fredoka-Bold", size: 28))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text("This helps us tailor your experience")
                .font(.custom("Fredoka-Regular", size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 28)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(purposes, id: \.id) { purpose in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedPurpose = purpose.id
                        }
                    } label: {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(selectedPurpose == purpose.id ? Color.brandGreen.opacity(0.15) : Color(.systemGray6))
                                    .frame(width: 50, height: 50)

                                Image(systemName: purpose.icon)
                                    .font(.system(size: 22))
                                    .foregroundColor(selectedPurpose == purpose.id ? .brandGreen : .secondary)
                            }

                            Text(purpose.title)
                                .font(.custom("Fredoka-Medium", size: 14))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(height: 36)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedPurpose == purpose.id ? Color.brandGreen : Color(.systemGray4), lineWidth: selectedPurpose == purpose.id ? 2 : 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            OnboardingButton("Continue", isEnabled: selectedPurpose != nil, action: onContinue)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Step 5: Daily Goal
struct DailyGoalStep: View {
    @Binding var selectedGoal: String?
    let onContinue: () -> Void

    private let goals: [(id: String, title: String, duration: String, icon: String)] = [
        ("casual", "Casual", "5 min / day", "tortoise.fill"),
        ("regular", "Regular", "10 min / day", "hare.fill"),
        ("serious", "Serious", "15 min / day", "flame.fill"),
        ("intense", "Intense", "20 min / day", "bolt.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Choose a daily\npractice goal")
                .font(.custom("Fredoka-Bold", size: 28))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            Text("Consistency is the key to improvement")
                .font(.custom("Fredoka-Regular", size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 32)

            VStack(spacing: 0) {
                ForEach(goals, id: \.id) { goal in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedGoal = goal.id
                        }
                    } label: {
                        HStack {
                            HStack(spacing: 10) {
                                Image(systemName: goal.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(selectedGoal == goal.id ? .brandGreen : .secondary)
                                    .frame(width: 24)

                                Text(goal.title)
                                    .font(.custom("Fredoka-SemiBold", size: 17))
                                    .foregroundColor(selectedGoal == goal.id ? .brandGreen : .primary)
                            }

                            Spacer()

                            Text(goal.duration)
                                .font(.custom("Fredoka-Medium", size: 15))
                                .foregroundColor(selectedGoal == goal.id ? .brandGreen : .secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            selectedGoal == goal.id
                            ? Color.brandGreen.opacity(0.06)
                            : Color.clear
                        )
                    }

                    if goal.id != goals.last?.id {
                        Divider()
                            .padding(.leading, 54)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)

            Spacer()

            OnboardingButton("Continue", isEnabled: selectedGoal != nil, action: onContinue)
                .padding(.bottom, 50)
        }
    }
}

// MARK: - Step 6: Ready
struct ReadyStep: View {
    let targetBandRange: String
    let onGetStarted: () -> Void
    @State private var appear = false
    @State private var confettiScale: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Celebration icon
            ZStack {
                // Confetti-like decorative circles
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(confettiColor(for: i))
                        .frame(width: 12, height: 12)
                        .offset(
                            x: cos(Double(i) * .pi / 4) * 80,
                            y: sin(Double(i) * .pi / 4) * 80
                        )
                        .scaleEffect(confettiScale)
                        .opacity(appear ? 0.7 : 0)
                }

                Circle()
                    .fill(Color.brandGreen.opacity(0.12))
                    .frame(width: 130, height: 130)
                    .scaleEffect(appear ? 1 : 0.5)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.brandGreen)
                    .scaleEffect(appear ? 1 : 0.3)
            }
            .padding(.bottom, 36)

            Text("You're all set!")
                .font(.custom("Fredoka-Bold", size: 32))
                .foregroundColor(.primary)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            Text("Your personalized IELTS Speaking\nprep plan is ready")
                .font(.custom("Fredoka-Regular", size: 16))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .padding(.top, 12)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            // Summary card
            VStack(spacing: 16) {
                SummaryRow(label: "Target Score", value: "Band \(targetBandRange)", icon: "target")
                Divider()
                SummaryRow(label: "Test Format", value: "3 Parts, 15 min", icon: "list.number")
                Divider()
                SummaryRow(label: "AI Feedback", value: "Instant scoring", icon: "brain.head.profile")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.brandGreen.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 30)

            Spacer()

            OnboardingButton("Start Practicing", action: onGetStarted)
                .opacity(appear ? 1 : 0)
                .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.2)) {
                appear = true
            }
            withAnimation(.spring(response: 1.0, dampingFraction: 0.5).delay(0.5)) {
                confettiScale = 1.0
            }
        }
    }

    private func confettiColor(for index: Int) -> Color {
        let colors: [Color] = [.brandGreen, .warningOrange, .lightBlue, .rewardYellow, .primaryVariant, .errorRed, .infoBlue, .brandGreen]
        return colors[index % colors.count]
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.brandGreen)
                .frame(width: 24)

            Text(label)
                .font(.custom("Fredoka-Medium", size: 15))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.custom("Fredoka-SemiBold", size: 15))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    OnboardingView()
}
