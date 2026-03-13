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

    private var scoreColor: Color {
        switch result.bandScore {
        case 7.0...9.0: return Color(red: 76/255, green: 175/255, blue: 80/255)
        case 6.0..<7.0: return .warningOrange
        default: return .errorRed
        }
    }

    private var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: result.date, to: now).day ?? 0

        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days) days ago" }
        if days < 30 { return "\(days / 7)w ago" }
        return result.date.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Score ring
                ZStack {
                    Circle()
                        .stroke(scoreColor.opacity(0.15), lineWidth: 4)
                        .frame(width: 54, height: 54)

                    Circle()
                        .trim(from: 0, to: result.bandScore / 9.0)
                        .stroke(
                            scoreColor,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 54, height: 54)
                        .rotationEffect(.degrees(-90))

                    Text(String(format: "%.1f", result.bandScore))
                        .font(.custom("Fredoka-Bold", size: 17))
                        .foregroundColor(scoreColor)
                }

                // Info
                VStack(alignment: .leading, spacing: 5) {
                    Text(result.date, style: .date)
                        .font(.custom("Fredoka-SemiBold", size: 16))
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(result.duration)
                                .font(.custom("Fredoka-Regular", size: 12))
                        }
                        .foregroundColor(.secondary)

                        Text(relativeDate)
                            .font(.custom("Fredoka-Medium", size: 12))
                            .foregroundColor(scoreColor.opacity(0.8))
                    }
                }

                Spacer()

                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(scoreColor.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
