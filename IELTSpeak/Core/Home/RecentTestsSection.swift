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
        HStack {
            Text("Recent Tests")
                .font(.custom("Fredoka-Medium", size: 18))
                .foregroundColor(.primary)
            
            Spacer()
            
            Button("View All") {
                // Handle view all
            }
            .font(.custom("Fredoka-Regular", size: 14))
            .foregroundColor(.blue)
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
            Image(systemName: "waveform.badge.mic")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            Text("No tests yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Take your first speaking test to get AI feedback and track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}


