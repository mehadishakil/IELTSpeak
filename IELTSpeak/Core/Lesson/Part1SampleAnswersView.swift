//
//  Part1SampleAnswersView.swift
//  IELTSpeak
//
//  Created by Claude on 11/8/25.
//

import SwiftUI

struct Part1SampleAnswersView: View {
    let data: [Part1SampleAnswer]

    @State private var searchText = ""

    private let accentPurple = Color(red: 100/255, green: 96/255, blue: 180/255)

    private var filteredData: [Part1SampleAnswer] {
        var filtered = data

        if !searchText.isEmpty {
            filtered = filtered.filter { answer in
                answer.topic.localizedCaseInsensitiveContains(searchText) ||
                answer.questions.contains { question in
                    question.question.localizedCaseInsensitiveContains(searchText) ||
                    question.answer.localizedCaseInsensitiveContains(searchText)
                }
            }
        }

        return filtered
    }

    private var totalQuestionCount: Int {
        filteredData.reduce(0) { $0 + $1.questions.count }
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

                // Stats bar
                HStack {
                    Text("\(filteredData.count) topics")
                        .font(.custom("Fredoka-Medium", size: 13))
                        .foregroundColor(.secondary)

                    Circle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 4, height: 4)

                    Text("\(totalQuestionCount) questions")
                        .font(.custom("Fredoka-Medium", size: 13))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 8)

                // Content
                LazyVStack(spacing: 14) {
                    ForEach(filteredData) { topicData in
                        Part1TopicCard(topicData: topicData, accentColor: accentPurple)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("Part 1 Sample Answers")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
    }
}

struct Part1TopicCard: View {
    let topicData: Part1SampleAnswer
    var accentColor: Color = Color(red: 100/255, green: 96/255, blue: 180/255)
    @State private var isExpanded = false
    private let dataManager = LessonDataManager.shared

    private var topicIcon: String {
        let topic = topicData.topic.lowercased()
        if topic.contains("food") || topic.contains("cook") { return "fork.knife" }
        if topic.contains("sport") || topic.contains("exercise") { return "figure.run" }
        if topic.contains("music") || topic.contains("song") { return "music.note" }
        if topic.contains("travel") || topic.contains("holiday") { return "airplane" }
        if topic.contains("work") || topic.contains("job") { return "briefcase.fill" }
        if topic.contains("study") || topic.contains("school") || topic.contains("education") { return "graduationcap.fill" }
        if topic.contains("home") || topic.contains("house") || topic.contains("indoor") { return "house.fill" }
        if topic.contains("friend") || topic.contains("people") || topic.contains("family") { return "person.2.fill" }
        if topic.contains("book") || topic.contains("read") { return "book.fill" }
        if topic.contains("weather") || topic.contains("season") { return "cloud.sun.fill" }
        if topic.contains("shop") || topic.contains("cloth") || topic.contains("fashion") { return "bag.fill" }
        if topic.contains("name") { return "textformat" }
        if topic.contains("bill") || topic.contains("money") { return "creditcard.fill" }
        if topic.contains("bicycle") || topic.contains("transport") { return "bicycle" }
        if topic.contains("animal") || topic.contains("pet") { return "pawprint.fill" }
        if topic.contains("phone") || topic.contains("technology") { return "iphone" }
        if topic.contains("film") || topic.contains("movie") || topic.contains("tv") { return "film" }
        return "bubble.left.fill"
    }

    private var topicColor: Color {
        let hash = abs(topicData.topic.hashValue)
        let colors: [Color] = [
            Color(red: 100/255, green: 96/255, blue: 180/255),  // purple
            Color(red: 66/255, green: 165/255, blue: 245/255),  // blue
            Color(red: 76/255, green: 175/255, blue: 80/255),   // green
            Color(red: 255/255, green: 152/255, blue: 0/255),   // orange
            Color(red: 236/255, green: 64/255, blue: 122/255),  // pink
            Color(red: 0/255, green: 172/255, blue: 193/255),   // teal
        ]
        return colors[hash % colors.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    isExpanded.toggle()
                }
                if isExpanded {
                    markTopicStudied()
                }
            } label: {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(topicColor.opacity(0.12))
                            .frame(width: 48, height: 48)

                        Image(systemName: topicIcon)
                            .font(.system(size: 20))
                            .foregroundColor(topicColor)
                    }

                    // Title & count
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(topicData.topic)
                                .font(.custom("Fredoka-SemiBold", size: 17))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)

                            if isTopicStudied {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.brandGreen)
                            }
                        }

                        Text("\(topicData.questions.count) questions")
                            .font(.custom("Fredoka-Medium", size: 13))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

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

            // Questions (Expandable)
            if isExpanded {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 1)
                        .padding(.horizontal, 18)

                    VStack(spacing: 12) {
                        ForEach(Array(topicData.questions.enumerated()), id: \.element.id) { index, question in
                            Part1QuestionCard(
                                question: question,
                                index: index + 1,
                                accentColor: topicColor
                            )
                        }
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

    private var isTopicStudied: Bool {
        topicData.questions.allSatisfy { q in
            let stableId = "sample_p1_\(topicData.topic.lowercased())_\(q.question.prefix(40).lowercased())"
            return dataManager.isItemStudied(stableId)
        }
    }

    private func markTopicStudied() {
        for question in topicData.questions {
            let stableId = "sample_p1_\(topicData.topic.lowercased())_\(question.question.prefix(40).lowercased())"
            dataManager.markItemCompleted(
                itemId: stableId,
                subcategoryId: "sample-answers-part1",
                categoryId: "sample-answers"
            )
        }
    }
}

struct Part1QuestionCard: View {
    let question: Part1Question
    var index: Int = 1
    var accentColor: Color = Color(red: 100/255, green: 96/255, blue: 180/255)
    @State private var showAlternativeAnswer = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question header
            HStack(alignment: .top, spacing: 10) {
                Text("Q\(index)")
                    .font(.custom("Fredoka-Bold", size: 12))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 24)
                    .background(
                        Capsule()
                            .fill(accentColor)
                    )

                Text(question.question)
                    .font(.custom("Fredoka-SemiBold", size: 15))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Sample Answer
            VStack(alignment: .leading, spacing: 8) {
                Label {
                    Text("Sample Answer")
                        .font(.custom("Fredoka-Medium", size: 12))
                } icon: {
                    Image(systemName: "text.quote")
                        .font(.system(size: 10))
                }
                .foregroundColor(accentColor)

                Text(question.answer)
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

            // Alternative Answer
            if let alternativeAnswer = question.alternative_answer, !alternativeAnswer.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showAlternativeAnswer.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))

                            Text("Alternative Answer")
                                .font(.custom("Fredoka-Medium", size: 12))

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                                .rotationEffect(.degrees(showAlternativeAnswer ? 180 : 0))
                        }
                        .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                    }
                    .buttonStyle(PlainButtonStyle())

                    if showAlternativeAnswer {
                        Text(alternativeAnswer)
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
                        .fill(Color(red: 76/255, green: 175/255, blue: 80/255).opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 76/255, green: 175/255, blue: 80/255).opacity(0.15), lineWidth: 1)
                        )
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray5).opacity(0.8), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationView {
        Part1SampleAnswersView(data: [])
    }
}