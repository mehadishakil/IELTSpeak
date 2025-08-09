//
//  TestHeaderView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

struct TestHeaderView: View {
    let currentPhase: TestPhase
    let currentPart: Int
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack {
                    
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("IELTS Speaking Test")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        if currentPhase == .testing {
                            Text("Part \(currentPart) of 3")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                    
                    Button(action: onDismiss) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .frame(height: 80)
        }
    }
}
