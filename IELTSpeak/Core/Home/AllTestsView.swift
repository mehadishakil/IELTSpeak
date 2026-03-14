//
//  AllTestsView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 14/3/26.
//

import SwiftUI

struct AllTestsView: View {
    let testResults: [TestResult]
    let onTestSelected: (TestResult) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredResults: [TestResult] {
        if searchText.isEmpty {
            return testResults
        }
        return testResults.filter { result in
            let dateString = result.date.formatted(.dateTime.day().month(.wide).year())
            let scoreString = String(format: "%.1f", result.bandScore)
            let query = searchText.lowercased()
            return dateString.lowercased().contains(query)
                || scoreString.contains(query)
                || result.duration.lowercased().contains(query)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 245/255, green: 245/255, blue: 245/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                            )
                    }

                    Spacer()

                    Text("All Tests")
                        .font(.custom("Fredoka-SemiBold", size: 20))
                        .foregroundColor(.primary)

                    Spacer()

                    // Invisible spacer to balance the back button
                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)

                    TextField("Search by date, score...", text: $searchText)
                        .font(.custom("Fredoka-Regular", size: 15))

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Results count
                HStack {
                    Text("\(filteredResults.count) test\(filteredResults.count == 1 ? "" : "s")")
                        .font(.custom("Fredoka-Medium", size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // Test list
                ScrollView {
                    if filteredResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No tests found")
                                .font(.custom("Fredoka-Medium", size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredResults) { result in
                                ModernTestCard(result: result) {
                                    onTestSelected(result)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
