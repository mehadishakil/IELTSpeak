//
//  ModernTestCard.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import SwiftUI

struct ModernTestCard: View {
    let result: TestResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.3), lineWidth: 3)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: result.bandScore / 9.0)
                        .stroke(scoreColor, lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text(String(format: "%.1f", result.bandScore))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(scoreColor)
                }
                
                // Test Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.date, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(result.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Label(result.duration, systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("AI Feedback", systemImage: "brain.head.profile")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var scoreColor: Color {
        switch result.bandScore {
        case 7.0...9.0: return .green
        case 6.0..<7.0: return .orange
        default: return .red
        }
    }
}
