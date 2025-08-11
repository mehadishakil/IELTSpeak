//
//  Part3SampleAnswersView.swift
//  IELTSpeak
//
//  Created by Claude on 11/8/25.
//

import SwiftUI

struct Part3SampleAnswersView: View {
    let data: [Part3SampleAnswer]
    
    @State private var searchText = ""
    @State private var selectedTopic: String? = nil
    
    private var availableTopics: [String] {
        let topics = data.map { $0.topic }.sorted()
        return ["All Topics"] + topics
    }
    
    private var filteredData: [Part3SampleAnswer] {
        var filtered = data
        
        // Filter by topic
        if let selectedTopic = selectedTopic, selectedTopic != "All Topics" {
            filtered = filtered.filter { $0.topic == selectedTopic }
        }
        
        // Filter by search text
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Section
            VStack(spacing: 16) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search questions or answers...", text: $searchText)
                        .font(.custom("Fredoka-Regular", size: 16))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Topic Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(availableTopics, id: \.self) { topic in
                            Part3TopicFilterChip(
                                title: topic,
                                isSelected: selectedTopic == topic
                            ) {
                                if selectedTopic == topic {
                                    selectedTopic = nil
                                } else {
                                    selectedTopic = topic
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Info Banner
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.purple)
                    
                    Text("Part 3: Two-way Discussion - Abstract and complex questions related to Part 2 topic")
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
            
            // Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredData) { topicData in
                        Part3TopicCard(topicData: topicData)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Part 3 Sample Answers")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if selectedTopic == nil {
                selectedTopic = "All Topics"
            }
        }
    }
}

struct Part3TopicFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Fredoka-Medium", size: 14))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.purple : Color(.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Part3TopicCard: View {
    let topicData: Part3SampleAnswer
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(topicData.topic)
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text("\(topicData.questions.count) discussion questions")
                            .font(.custom("Fredoka-Medium", size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Questions (Expandable)
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(topicData.questions) { question in
                        Part3QuestionCard(question: question)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct Part3QuestionCard: View {
    let question: Part3Question
    @State private var showAlternativeAnswer = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question
            Text(question.question)
                .font(.custom("Fredoka-SemiBold", size: 16))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Main Answer
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Sample Answer")
                        .font(.custom("Fredoka-Medium", size: 12))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.purple.opacity(0.1))
                        )
                    
                    Spacer()
                }
                
                Text(question.answer)
                    .font(.custom("Fredoka-Regular", size: 14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            
            // Alternative Answer (if available)
            if let alternativeAnswer = question.alternative_answer, !alternativeAnswer.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlternativeAnswer.toggle()
                            }
                        }) {
                            HStack {
                                Text("Alternative Answer")
                                    .font(.custom("Fredoka-Medium", size: 12))
                                    .foregroundColor(.indigo)
                                
                                Image(systemName: showAlternativeAnswer ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.indigo)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.indigo.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                    }
                    
                    if showAlternativeAnswer {
                        Text(alternativeAnswer)
                            .font(.custom("Fredoka-Regular", size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                                removal: .opacity.combined(with: .scale(scale: 0.95))
                            ))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.indigo.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.indigo.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Speaking Tips for Part 3
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption2)
                    
                    Text("Part 3 Tips")
                        .font(.custom("Fredoka-SemiBold", size: 11))
                        .foregroundColor(.orange)
                }
                
                Text("• Give detailed, analytical responses • Use examples and explanations • Show complex thinking • Connect ideas logically")
                    .font(.custom("Fredoka-Regular", size: 11))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.orange.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                    )
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationView {
        Part3SampleAnswersView(data: [])
    }
}