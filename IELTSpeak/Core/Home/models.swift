import Foundation

struct QuestionItem {
    let id: String // Keep as String for consistency with backend
    let part: Int
    let order: Int
    let questionText: String
    let audioFile: Data
}

// Update QuestionRow to handle integer ID from database
struct QuestionRow: Decodable {
    let id: Int          // Changed to Int to match database
    let test_id: Int
    let part: Int
    let order: Int
    let question_text: String
    let audio_url: String
    let created_at: String
    
    // Convert to String ID for QuestionItem
    var stringId: String {
        return String(id)
    }
}

struct TestResult: Identifiable {
    let id: String
    let date: Date
    let bandScore: Double
    let duration: String
    let criteriaScores: [String: Double]
    let overallFeedback: String
    let conversations: [Conversation]
}

struct Conversation: Identifiable {
    let id = UUID()
    let part: Int
    let order: Int
    let question: String
    let answer: String
    let errors: [ConversationError]
}

struct ConversationError {
    let word: String
    let correction: String
    let range: NSRange
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

struct TestSession {
    let id: String
    let userId: String
    let templateId: String
    let status: String
    let startedAt: Date
}

struct TestResults {
    let sessionId: String
    let overallBandScore: Double
    let fluencyScore: Double
    let pronunciationScore: Double
    let grammarScore: Double
    let vocabularyScore: Double
    let completedAt: Date
    let responses: [ResponseResult]
}

struct ResponseResult {
    let transcript: String
    let fluencyScore: Double
    let pronunciationScore: Double
    let processingOrder: Int
}


//import Foundation
//
//struct QuestionItem {
//    let id: String
//    let part: Int
//    let order: Int
//    let questionText: String
//    let audioFile: Data
//}
//
//struct QuestionRow: Decodable {
//    let id: String
//    let test_id: Int
//    let part: Int
//    let order: Int
//    let question_text: String
//    let audio_url: String
//    let created_at: String
//}
//
//struct TestResult: Identifiable {
//    let id: String
//    let date: Date
//    let bandScore: Double
//    let duration: String
//    let criteriaScores: [String: Double]
//    let overallFeedback: String
//    let conversations: [Conversation]
//}
//
//struct Conversation: Identifiable {
//    let id = UUID()
//    let part: Int
//    let order: Int
//    let question: String
//    let answer: String
//    let errors: [ConversationError]
//}
//
//struct ConversationError {
//    let word: String
//    let correction: String
//    let range: NSRange
//}
//                  
//struct TestPart {
//    let part: Int
//    let title: String
//    let duration: String
//    let questions: [String]
//}
//
//
//enum TestPhase {
//    case preparation
//    case testing
//    case processing
//    case completed
//}
//
//struct TestSession {
//    let id: String
//    let userId: String
//    let templateId: String
//    let status: String
//    let startedAt: Date
//}
//
//struct TestResults {
//    let sessionId: String
//    let overallBandScore: Double
//    let fluencyScore: Double
//    let pronunciationScore: Double
//    let grammarScore: Double
//    let vocabularyScore: Double
//    let completedAt: Date
//    let responses: [ResponseResult]
//}
//
//struct ResponseResult {
//    let transcript: String
//    let fluencyScore: Double
//    let pronunciationScore: Double
//    let processingOrder: Int
//}
