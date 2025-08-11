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
    @State private var selectedTopic: String? = nil
    
    private var availableTopics: [String] {
        let topics = data.map { $0.topic }.sorted()
        return ["All Topics"] + topics
    }
    
    private var filteredData: [Part1SampleAnswer] {
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
                            TopicFilterChip(
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
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
            
            // Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredData) { topicData in
                        Part1TopicCard(topicData: topicData)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Part 1 Sample Answers")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            if selectedTopic == nil {
                selectedTopic = "All Topics"
            }
        }
    }
}

struct TopicFilterChip: View {
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
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Part1TopicCard: View {
    let topicData: Part1SampleAnswer
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
                        
                        Text("\(topicData.questions.count) questions")
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
                        Part1QuestionCard(question: question)
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

struct Part1QuestionCard: View {
    let question: Part1Question
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
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.blue.opacity(0.1))
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
                                    .foregroundColor(.green)
                                
                                Image(systemName: showAlternativeAnswer ? "chevron.up" : "chevron.down")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green.opacity(0.1))
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
                        .fill(Color.green.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green.opacity(0.2), lineWidth: 1)
                        )
                )
            }
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
        Part1SampleAnswersView(data: [])
    }
}