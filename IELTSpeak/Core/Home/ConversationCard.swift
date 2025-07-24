//
//  ConversationCard.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import SwiftUI

struct ConversationCard: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Part \(conversation.part)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue)
                    )
                
                Spacer()
                
                Text("\(conversation.errors.count) error\(conversation.errors.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Question
            VStack(alignment: .leading, spacing: 8) {
                Text("Question:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(conversation.question)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
            
            // Answer with error highlighting
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Answer:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HighlightedText(text: conversation.answer, errors: conversation.errors)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6))
                    )
            }
            
            // Errors
            if !conversation.errors.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Corrections:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ForEach(conversation.errors, id: \.word) { error in
                        HStack {
                            Text(error.word)
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .strikethrough()
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(error.correction)
                                .font(.subheadline)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
