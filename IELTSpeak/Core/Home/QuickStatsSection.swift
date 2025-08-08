//
//  QuickStatsSection.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 17/7/25.
//

import SwiftUI

// MARK: - Quick Stats Section
struct QuickStatsSection: View {
    let averageScore: Double
    let testResults: [TestResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.custom("Fredoka-Medium", size: 18))
                .foregroundColor(.primary)
            
            StatsCardsRow(
                averageScore: averageScore,
                testCount: testResults.count
            )
            
            ScoreBarChart(testResults: testResults)
        }
        .padding()
    }
}

// MARK: - Stats Cards Row
struct StatsCardsRow: View {
    let averageScore: Double
    let testCount: Int
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Average Score",
                value: String(format: "%.1f", averageScore),
                subtitle: "Band Score",
                color: .blue,
                icon: "chart.line.uptrend.xyaxis"
            )
            
            StatCard(
                title: "Tests Taken",
                value: "\(testCount)",
                subtitle: "Total",
                color: .green,
                icon: "checkmark.circle.fill"
            )
            
            StatCard(
                title: "Improvement",
                value: "+1.5",
                subtitle: "This Month",
                color: .orange,
                icon: "arrow.up.circle.fill"
            )
        }
    }
}
