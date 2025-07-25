//
//  QuestionAnswerBlock.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 25/7/25.
//

import SwiftUI

struct QuestionAnswerBlock: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Q1:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(conversation.question)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("You:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HighlightedText(text: conversation.answer, errors: conversation.errors)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5).opacity(0.5))
            )

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
                .padding(.horizontal, 8)
            }
        }
        .padding(.vertical, 8)
    }
}
