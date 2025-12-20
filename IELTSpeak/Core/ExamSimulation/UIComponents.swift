//
//  Components.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

struct AIAvatarView: View {
    let isActive: Bool
    let color: Color
    let icon: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 100, height: 100)
            
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 80, height: 80)
                .scaleEffect(isActive ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isActive)
            
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
        }
        
    }
}

struct SpeakingIndicator: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: true)
            
            Text(text)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct RecordingTimer: View {
    let recordingTime: TimeInterval
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(1.2)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: true)
            
            Text(timeString(from: recordingTime))
                .font(.caption)
                .foregroundColor(.red)
                .fontWeight(.medium)
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct WaveformView: View {
    let data: [Double]
    let color: Color
    let barWidth: CGFloat
    let spacing: CGFloat
    
    init(data: [Double], color: Color, barWidth: CGFloat = 3, spacing: CGFloat = 3) {
        self.data = data
        self.color = color
        self.barWidth = barWidth
        self.spacing = spacing
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: spacing) {
                ForEach(0..<data.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: barWidth / 2)
                        .fill(color.opacity(0.8))
                        .frame(width: barWidth, height: max(2, CGFloat(data[index] * 25 + 3)))
                        .animation(.easeOut(duration: 0.05), value: data[index])
                }
            }
            .frame(height: 30)
        }
        .padding(.horizontal, 20)
    }
}


struct ProgressBarDivider: View {
    let currentPart: Int

    var body: some View {
        VStack(spacing: 0) {
            // Thick progress bar with text inside
            HStack(spacing: 4) {
                ForEach(1...3, id: \.self) { partNumber in
                    ZStack {
                        // Background bar
                        RoundedRectangle(cornerRadius: 8)
                            .fill(partNumber <= currentPart ?
                                  Color.secondary :
                                  Color.gray.opacity(0.3)
                            )
                            .frame(height: 44)

                        // Text inside the bar
                        Text("Part \(partNumber)")
                            .font(.system(size: 15, weight: partNumber == currentPart ? .bold : .semibold))
                            .foregroundColor(partNumber <= currentPart ? .white : .gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

