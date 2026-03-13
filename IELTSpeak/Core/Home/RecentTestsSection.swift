//
//  RecentTestsSection.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

// MARK: - Recent Tests Section
struct RecentTestsSection: View {
    let testResults: [TestResult]
    let onTestSelected: (TestResult) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            RecentTestsHeader()

            if testResults.isEmpty {
                EmptyTestsState()
            } else {
                TestResultsList(
                    testResults: testResults,
                    onTestSelected: onTestSelected
                )
            }
        }
    }
}

// MARK: - Recent Tests Header
struct RecentTestsHeader: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Recent Tests")
                .font(.custom("Fredoka-SemiBold", size: 20))
                .foregroundColor(.primary)

            Spacer()

            Button("View All") {
                // Handle view all
            }
            .font(.custom("Fredoka-Medium", size: 14))
            .foregroundColor(.brandGreen)
        }
    }
}

// MARK: - Test Results List
struct TestResultsList: View {
    let testResults: [TestResult]
    let onTestSelected: (TestResult) -> Void

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(testResults) { result in
                ModernTestCard(result: result) {
                    onTestSelected(result)
                }
            }
        }
    }
}

// MARK: - Empty Tests State
struct EmptyTestsState: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "waveform.badge.mic")
                    .font(.system(size: 34))
                    .foregroundColor(.brandGreen)
            }

            Text("No tests yet")
                .font(.custom("Fredoka-SemiBold", size: 20))
                .foregroundColor(.primary)

            Text("Take your first speaking test to get\nAI feedback and track your progress")
                .font(.custom("Fredoka-Regular", size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }
}
