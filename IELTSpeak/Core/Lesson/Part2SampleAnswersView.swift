//
//  Part2SampleAnswersView.swift
//  IELTSpeak
//
//  Created by Claude on 11/8/25.
//

import SwiftUI

struct Part2SampleAnswersView: View {
    let data: [Part2SampleAnswer]

    @State private var searchText = ""

    private let accentGreen = Color(red: 76/255, green: 175/255, blue: 80/255)

    private var filteredData: [Part2SampleAnswer] {
        if searchText.isEmpty {
            return data
        }

        return data.filter { answer in
            answer.question.localizedCaseInsensitiveContains(searchText) ||
            answer.answer1.localizedCaseInsensitiveContains(searchText) ||
            (answer.answer2?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)

                    TextField("Search questions or answers...", text: $searchText)
                        .font(.custom("Fredoka-Regular", size: 16))

                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Info Banner
                HStack(spacing: 10) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(accentGreen)
                        )

                    Text("Speak for 1-2 minutes on the given cue card topic")
                        .font(.custom("Fredoka-Medium", size: 13))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // Stats bar
                HStack {
                    Text("\(filteredData.count) cue card topics")
                        .font(.custom("Fredoka-Medium", size: 13))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 8)

                // Content
                LazyVStack(spacing: 14) {
                    ForEach(Array(filteredData.enumerated()), id: \.element.id) { index, questionData in
                        Part2QuestionCard(
                            questionData: questionData,
                            index: index + 1,
                            accentColor: accentGreen
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("Part 2 Sample Answers")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
    }
}

struct Part2QuestionCard: View {
    let questionData: Part2SampleAnswer
    var index: Int = 1
    var accentColor: Color = Color(red: 76/255, green: 175/255, blue: 80/255)
    @State private var isExpanded = false
    @State private var showSecondAnswer = false

    private let altAnswerColor = Color(red: 100/255, green: 96/255, blue: 180/255)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 14) {
                    // Number badge
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(accentColor.opacity(0.12))
                            .frame(width: 48, height: 48)

                        Text("\(index)")
                            .font(.custom("Fredoka-Bold", size: 20))
                            .foregroundColor(accentColor)
                    }

                    // Question text
                    Text(questionData.question)
                        .font(.custom("Fredoka-SemiBold", size: 15))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 2)

                    Spacer(minLength: 8)

                    // Expand icon
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())

            // Answers Section (Expandable)
            if isExpanded {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.horizontal, 18)

                    VStack(spacing: 12) {
                        // Answer 1
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text("Sample Answer 1")
                                    .font(.custom("Fredoka-Medium", size: 12))
                            } icon: {
                                Image(systemName: "text.quote")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(accentColor)

                            Text(questionData.answer1)
                                .font(.custom("Fredoka-Regular", size: 14))
                                .foregroundColor(.primary.opacity(0.85))
                                .multilineTextAlignment(.leading)
                                .lineSpacing(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(accentColor.opacity(0.06))
                        )

                        // Answer 2 (if available)
                        if let answer2 = questionData.answer2, !answer2.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        showSecondAnswer.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 11))

                                        Text("Sample Answer 2")
                                            .font(.custom("Fredoka-Medium", size: 12))

                                        Spacer()

                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10, weight: .semibold))
                                            .rotationEffect(.degrees(showSecondAnswer ? 180 : 0))
                                    }
                                    .foregroundColor(altAnswerColor)
                                }
                                .buttonStyle(PlainButtonStyle())

                                if showSecondAnswer {
                                    Text(answer2)
                                        .font(.custom("Fredoka-Regular", size: 14))
                                        .foregroundColor(.primary.opacity(0.85))
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .transition(.opacity)
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(altAnswerColor.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(altAnswerColor.opacity(0.15), lineWidth: 1)
                                    )
                            )
                        }

                        // Tips
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Speaking Tips")
                                    .font(.custom("Fredoka-SemiBold", size: 12))
                                    .foregroundColor(.orange)

                                Text("Cover all cue card points. Use varied vocabulary and sentence structures. Aim for 1-2 minutes of fluent speech.")
                                    .font(.custom("Fredoka-Regular", size: 12))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.orange.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                }
                .transition(.opacity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationView {
        Part2SampleAnswersView(data: [])
    }
}
