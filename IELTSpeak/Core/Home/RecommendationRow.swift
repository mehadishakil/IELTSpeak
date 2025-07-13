//
//  RecommendationRow.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import SwiftUI

struct RecommendationRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
