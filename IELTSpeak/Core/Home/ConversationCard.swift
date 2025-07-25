////
////  ConversationCard.swift
////  IELTSpeak
////
////  Created by Mehadi Hasan on 13/7/25.
////
//
//import SwiftUI
//
//struct ConversationCard: View {
//    let conversation: Conversation
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                Text("Part \(conversation.part)")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.blue)
//                    )
//
//                Spacer()
//
//                Text("\(conversation.errors.count) error\(conversation.errors.count == 1 ? "" : "s")")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            // Question
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Question:")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//
//                Text(conversation.question)
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .padding(12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color(.systemGray6))
//                    )
//            }
//
//            // Answer with error highlighting
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Your Answer:")
//                    .font(.subheadline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//
//                HighlightedText(text: conversation.answer, errors: conversation.errors)
//                    .padding(12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color(.systemGray6))
//                    )
//            }
//
//            // Errors
//            if !conversation.errors.isEmpty {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Corrections:")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//
//                    ForEach(conversation.errors, id: \.word) { error in
//                        HStack {
//                            Text(error.word)
//                                .font(.subheadline)
//                                .foregroundColor(.red)
//                                .strikethrough()
//
//                            Image(systemName: "arrow.right")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//
//                            Text(error.correction)
//                                .font(.subheadline)
//                                .foregroundColor(.green)
//                                .fontWeight(.medium)
//
//                            Spacer()
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//        )
//    }
//}

import SwiftUI

struct PartConversationCard: View {
    let partNumber: Int
    let conversationsInPart: [Conversation]
    @State private var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 0) { // Set spacing to 0 here to control it manually
                ForEach(conversationsInPart.sorted(by: { $0.order < $1.order }).indices, id: \.self) { index in
                    QuestionAnswerBlock(conversation: conversationsInPart[index])
                    
                    if index < conversationsInPart.count - 1 {
                        Divider()
                            .padding(.vertical, 10)
                    }
                }
            }
            .padding(.top, 10) // Padding for content inside DisclosureGroup
        } label: {
            HStack {
                Text("Part \(partNumber)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                let totalErrors = conversationsInPart.reduce(0) { $0 + $1.errors.count }
                if totalErrors > 0 {
                    Text("\(totalErrors) error\(totalErrors == 1 ? "" : "s")")
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.red.opacity(0.1)))
                }
            }
            .padding(.vertical, 8)
        }
        .padding(16) // This padding is for the overall card around the disclosure group
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5) // Keep card shadow
        )
    }
}
