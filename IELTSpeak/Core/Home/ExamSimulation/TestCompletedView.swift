//
//  ExamCompletedView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

// MARK: - Completed View
struct TestCompletedView: View {
    let onViewResults: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            CompletionSuccess()
            ResultsButton(onViewResults: onViewResults)
            Spacer()
        }
        .padding(.top, 50)
    }
}

struct CompletionSuccess: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Test Completed!")
                .font(.custom("Fredoka-Regular", size: 26))
                .fontWeight(.semibold)
                .foregroundColor(.primary.opacity(0.8))
            
            Text("Your test has been successfully processed. You can now view your detailed feedback and scores.")
                .font(.custom("Fredoka-Regular", size: 16))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

struct ResultsButton: View {
    let onViewResults: () -> Void
    
    var body: some View {
        Button(action: onViewResults) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                
                Text("View Results")
                    .font(.custom("Fredoka-Regular", size: 20))
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.green)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
    }
}
