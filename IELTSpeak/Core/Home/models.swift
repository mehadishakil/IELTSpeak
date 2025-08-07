import Foundation

struct QuestionItem {
    let id: String // Keep as String for consistency with backend
    let part: Int
    let order: Int
    let questionText: String
    let audioFile: Data
}

// Update QuestionRow to match actual database schema
struct QuestionRow: Decodable {
    let id: String              // Database questions.id is UUID
    let test_template_id: String // UUID for test template
    let part_number: Int        // Database uses part_number, not part
    let question_order: Int     // Database uses question_order, not order
    let question_text: String   // This matches database
    let audio_file_url: String  // Database uses audio_file_url, not audio_url
    let created_at: String      // This matches database
    let transcript: String?     // Optional transcript field
    
    // Computed properties for backward compatibility
    var part: Int {
        return part_number
    }
    
    var order: Int {
        return question_order
    }
    
    var audio_url: String {
        return audio_file_url
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


