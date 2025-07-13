//
//  models.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import Foundation


// MARK: - Data Models
struct TestResult: Identifiable {
    let id: String
    let date: Date
    let bandScore: Double
    let duration: String
    let parts: [Double]
    let overallFeedback: String
    let conversations: [Conversation]
}

struct Conversation: Identifiable {
    let id = UUID()
    let part: Int
    let question: String
    let answer: String
    let errors: [ConversationError]
}

struct ConversationError {
    let word: String
    let correction: String
    let range: NSRange
}

//struct QuestionItem {
//    let id: Int
//    let part: Int
//    let order: Int
//    let questionText: String
//    let audioFile: Audio
//}
