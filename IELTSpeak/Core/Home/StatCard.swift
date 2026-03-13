//
//  StatCard.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            // Value
            Text(value)
                .font(.custom("Fredoka-Bold", size: 22))
                .foregroundColor(.primary)

            // Labels
            VStack(spacing: 2) {
                Text(subtitle)
                    .font(.custom("Fredoka-Regular", size: 10))
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.custom("Fredoka-Medium", size: 11))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}
