//
//  HomeHeaderSection.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

// MARK: - Header Section Component
struct HomeHeaderSection: View {
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var greetingIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "sun.max.fill"
        case 12..<17: return "sun.min.fill"
        case 17..<21: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: greetingIcon)
                        .font(.system(size: 14))
                        .foregroundColor(.warningOrange)

                    Text(greeting)
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(.secondary)
                }

                Text("Practice IELTS\nSpeaking")
                    .font(.custom("Fredoka-Bold", size: 28))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
            }

            Spacer()

            // Decorative mic icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.brandGreen.opacity(0.15), Color.primaryVariant.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: "waveform.and.mic")
                    .font(.system(size: 24))
                    .foregroundColor(.brandGreen)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
