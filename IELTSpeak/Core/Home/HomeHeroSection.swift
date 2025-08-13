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
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: onStartTest) {
                ZStack {
                    HeroButtonBackground()
                    HeroButtonContent()
                }
            }
            .disabled(isLoading)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
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
        }
    }
}

struct HeroButtonBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue,
                Color.purple
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct HeroButtonContent: View {
    var body: some View {
        VStack(spacing: 12) {
            HeroButtonIcon()
            HeroButtonText()
            HeroButtonDetails()
        }
        .padding(.vertical, 30)
    }
}

struct HeroButtonIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 60)
            
            Image(systemName: "mic.fill")
                .font(.title)
                .foregroundColor(.white)
        }
    }
}

struct HeroButtonText: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Start Speaking Test")
                .font(.custom("Fredoka-SemiBold", size: 24))
                .foregroundColor(.white)
            
            Text("Get AI-powered feedback instantly")
                .font(.custom("Fredoka-Medium", size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}


struct TestDetailLabel: View {
    let text: String
    let icon: String
    
    var body: some View {
        Label(text, systemImage: icon)
            .font(.custom("Fredoka-Regular", size: 14))
            .foregroundColor(.white.opacity(0.8))
    }
}

struct HeroButtonDetails: View {
    var body: some View {
        HStack(spacing: 20) {
            TestDetailLabel(text: "15 min", icon: "clock")
            TestDetailLabel(text: "3 Parts", icon: "list.number")
            TestDetailLabel(text: "AI Scoring", icon: "brain.head.profile")
        }
    }
}
