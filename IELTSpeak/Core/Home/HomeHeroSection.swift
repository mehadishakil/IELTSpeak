//
//  HomeHeroSection.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

// MARK: - Hero Section Component
struct HomeHeroSection: View {
    let isLoading: Bool
    let onStartTest: () -> Void
    @State private var isPressed = false
    @State private var pulseAnimation = false

    var body: some View {
        Button(action: onStartTest) {
            HStack(spacing: 18) {
                // Animated mic icon
                ZStack {
                    // Pulse ring
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 62, height: 62)
                        .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                        .opacity(pulseAnimation ? 0 : 0.6)

                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }

                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text("Start Speaking Test")
                        .font(.custom("Fredoka-SemiBold", size: 20))
                        .foregroundColor(.white)

                    Text("AI-powered feedback instantly")
                        .font(.custom("Fredoka-Regular", size: 14))
                        .foregroundColor(.white.opacity(0.8))

                    // Detail pills
                    HStack(spacing: 8) {
                        TestDetailPill(text: "15 min", icon: "clock")
                        TestDetailPill(text: "3 Parts", icon: "list.number")
                    }
                    .padding(.top, 2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
            .background(
                LinearGradient(
                    colors: [Color.brandGreen, Color.primaryVariant],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(color: Color.primaryVariant.opacity(0.35), radius: 16, x: 0, y: 8)
        }
        .disabled(isLoading)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            if !pressing {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

struct TestDetailPill: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.custom("Fredoka-Medium", size: 11))
        }
        .foregroundColor(.white.opacity(0.9))
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
        )
    }
}

// Keep for backward compatibility
struct TestDetailLabel: View {
    let text: String
    let icon: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.custom("Fredoka-Regular", size: 14))
            .foregroundColor(.white.opacity(0.8))
    }
}
