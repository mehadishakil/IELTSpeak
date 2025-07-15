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
        VStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Spacer()
            
            Text(value)
                .font(.custom("Fredoka-Medium", size: 22))
                .foregroundColor(.primary.opacity(0.8))
            
            Spacer()
            
            Text(subtitle)
                .font(.custom("Fredoka-Regular", size: 10))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 0.2)
            
            Text(title)
                .font(.custom("Fredoka-Regular", size: 12))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
                .fill(color.opacity(0.1))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
