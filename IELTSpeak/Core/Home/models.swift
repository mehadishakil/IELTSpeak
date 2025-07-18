//
//  models.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//

import Foundation

struct QuestionItem {
    let part: Int
    let order: Int
    let questionText: String
    let audioFile: Data
}

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

struct QuestionRow: Decodable {
    let id: Int
    let test_id: Int
    let part: Int
    let order: Int
    let question_text: String
    let audio_url: String
    let created_at: String
}

struct TestPart {
    let part: Int
    let title: String
    let duration: String
    let questions: [String]
}


enum TestPhase {
    case preparation
    case testing
    case processing
    case completed
}

//struct QuestionItem {
//    let id: Int
//    let part: Int
//    let order: Int
//    let questionText: String
//    let audioFile: Audio
//}
