//
//  SampleAnswersView.swift
//  IELTSpeak
//
//  Created by Claude on 11/8/25.
//

import SwiftUI

struct SampleAnswersView: View {
    @StateObject private var dataManager = LessonDataManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    if let sampleAnswersData = dataManager.sampleAnswersData {
                        VStack(spacing: 16) {
                            // Part 1 Card
                            NavigationLink(destination: Part1SampleAnswersView(data: sampleAnswersData.part_1_sample_answers)) {
                                SampleAnswerPartCard(
                                    title: "IELTS Speaking Sample Answers Part 1",
                                    subtitle: "Introduction & Interview",
                                    description: "Personal questions about familiar topics",
                                    icon: "person.bubble",
                                    color: Color.blue,
                                    questionCount: sampleAnswersData.part_1_sample_answers.reduce(0) { $0 + $1.questions.count }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Part 2 Card
                            NavigationLink(destination: Part2SampleAnswersView(data: sampleAnswersData.part_2_sample_answers)) {
                                SampleAnswerPartCard(
                                    title: "IELTS Speaking Sample Answers Part 2",
                                    subtitle: "Individual Long Turn",
                                    description: "2-minute talk on a given topic",
                                    icon: "mic.circle",
                                    color: Color.green,
                                    questionCount: sampleAnswersData.part_2_sample_answers.count
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Part 3 Card
                            NavigationLink(destination: Part3SampleAnswersView(data: sampleAnswersData.part_3_sample_answers)) {
                                SampleAnswerPartCard(
                                    title: "IELTS Speaking Sample Answers Part 3",
                                    subtitle: "Two-way Discussion",
                                    description: "Abstract and complex questions",
                                    icon: "bubble.left.and.bubble.right",
                                    color: Color.purple,
                                    questionCount: sampleAnswersData.part_3_sample_answers.reduce(0) { $0 + $1.questions.count }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        loadingView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .navigationTitle("Sample Answers")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            if dataManager.sampleAnswersData == nil {
                dataManager.loadData()
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Study high-scoring IELTS speaking responses")
                    .font(.custom("Fredoka-Medium", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Text("Master all three parts of the IELTS Speaking test with our comprehensive collection of sample answers.")
                .font(.custom("Fredoka-Regular", size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 16)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading sample answers...")
                .font(.custom("Fredoka-SemiBold", size: 18))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
}

struct SampleAnswerPartCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let questionCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with icon and title
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Fredoka-SemiBold", size: 18))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text(description)
                    .font(.custom("Fredoka-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(color)
                    
                    Text("\(questionCount) sample questions")
                        .font(.custom("Fredoka-Medium", size: 12))
                        .foregroundColor(color)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    SampleAnswersView()
}