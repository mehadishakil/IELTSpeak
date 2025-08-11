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
        VStack(spacing: 0) {
            // Search Section
            VStack(spacing: 16) {
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
                
                // Info Banner
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("Part 2: Individual Long Turn - Speak for 1-2 minutes on the given topic")
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGroupedBackground))
            
            // Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredData) { questionData in
                        Part2QuestionCard(questionData: questionData)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Part 2 Sample Answers")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct Part2QuestionCard: View {
    let questionData: Part2SampleAnswer
    @State private var isExpanded = false
    @State private var showSecondAnswer = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Question Header (Always Visible)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "mic.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Text("Cue Card Topic")
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Hide Answers" : "Show Answers")
                            .font(.custom("Fredoka-Medium", size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.green)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Text(questionData.question)
                    .font(.custom("Fredoka-SemiBold", size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            // Answers Section (Expandable)
            if isExpanded {
                VStack(spacing: 16) {
                    // First Answer
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Sample Answer 1")
                                .font(.custom("Fredoka-SemiBold", size: 14))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                )
                            
                            Spacer()
                        }
                        
                        Text(questionData.answer1)
                            .font(.custom("Fredoka-Regular", size: 14))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Second Answer (if available)
                    if let answer2 = questionData.answer2, !answer2.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSecondAnswer.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text("Sample Answer 2")
                                            .font(.custom("Fredoka-SemiBold", size: 14))
                                            .foregroundColor(.purple)
                                        
                                        Image(systemName: showSecondAnswer ? "chevron.up" : "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.purple)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.purple.opacity(0.1))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                            
                            if showSecondAnswer {
                                Text(answer2)
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    
                    // Tips Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            
                            Text("Speaking Tips")
                                .font(.custom("Fredoka-SemiBold", size: 12))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("• Speak for 1-2 minutes without interruption")
                            Text("• Cover all points mentioned in the cue card")
                            Text("• Use varied vocabulary and sentence structures")
                            Text("• Practice fluency and natural pronunciation")
                        }
                        .font(.custom("Fredoka-Regular", size: 12))
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
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

#Preview {
    NavigationView {
        Part2SampleAnswersView(data: [])
    }
}