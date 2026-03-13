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
            HStack {
                Text("Your Progress")
                    .font(.custom("Fredoka-SemiBold", size: 20))
                    .foregroundColor(.primary)

                Spacer()
            }

            StatsCardsRow(
                averageScore: averageScore,
                testCount: testResults.count
            )

            ScoreBarChart(testResults: testResults)
        }
    }
}

// MARK: - Stats Cards Row
struct StatsCardsRow: View {
    let averageScore: Double
    let testCount: Int

    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Average Score",
                value: String(format: "%.1f", averageScore),
                subtitle: "Band Score",
                color: .brandGreen,
                icon: "chart.line.uptrend.xyaxis"
            )

            StatCard(
                title: "Tests Taken",
                value: "\(testCount)",
                subtitle: "Total",
                color: .infoBlue,
                icon: "checkmark.circle.fill"
            )

            StatCard(
                title: "Improvement",
                value: "+1.5",
                subtitle: "This Month",
                color: .warningOrange,
                icon: "arrow.up.circle.fill"
            )
        }
    }
}
