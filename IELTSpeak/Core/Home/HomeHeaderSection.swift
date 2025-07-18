//
//  HomeHeaderSection.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

// MARK: - Header Section Component
struct HomeHeaderSection: View {
    var body: some View {
        VStack(spacing: 0) {
            Color.clear
            
            HStack {
                Text("Practice IELTS Speaking")
                    .font(.custom("Fredoka-Semibold", size: 28))
                    .foregroundColor(.purple.opacity(0.9))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 0)
                .path(in: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 150))
        )
    }
}
