import Foundation
import Supabase
import AVFoundation


// MARK: - Codable structs for database operations
struct CreateSessionRequest: Codable {
    let user_id: String
    let test_template_id: String
    let status: String
}

struct SessionResponse: Codable {
    let id: String
    let user_id: String
    let test_template_id: String
    let status: String
    let created_at: String?
}

struct CreateResponseRequest: Codable {
    let test_session_id: String
    let question_id: String
    let audio_file_path: String
}

struct UpdateSessionRequest: Codable {
    let status: String
    let all_responses_uploaded: Bool
    let completed_at: String
}

struct EvaluationTriggerRequest: Codable {
    let session_id: String
    let user_id: String
    let template_id: String
    let triggered_at: String
}

struct SessionStatusResponse: Codable {
    let status: String
    let all_responses_uploaded: Bool?
}

struct TestResultsResponse: Codable {
    let id: String
    let status: String
    let overall_band_score: String?
    let fluency_score: String?
    let pronunciation_score: String?
    let grammar_score: String?
    let vocabulary_score: String?
    let completed_at: String?
}

struct ResponseScoreResult: Codable {
    let transcript: String?
    let fluency_score: String?
    let pronunciation_score: String?
    let processing_order: Int?
}

// MARK: - SupabaseService for Backend Integration
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    @Published var currentSession: TestSession?
    @Published var isProcessing = false
    
    private init() {}
    
    // MARK: - Test Session Management
    
    /// Create a new test session in Supabase
    func createTestSession(templateId: String = "550e8400-e29b-41d4-a716-446655440000") async throws -> TestSession {
            // Get current user
            let currentUser = try await supabase.auth.user()
            
            let sessionRequest = CreateSessionRequest(
                user_id: currentUser.id.uuidString,
                test_template_id: templateId,
                status: "in_progress"
            )
            
            let response: SessionResponse = try await supabase
                .from("test_sessions")
                .insert(sessionRequest)
                .select()
                .single()
                .execute()
                .value
            
            let session = TestSession(
                id: response.id,
                userId: response.user_id,
                templateId: response.test_template_id,
                status: response.status,
                startedAt: Date()
            )
            
            DispatchQueue.main.async {
                self.currentSession = session
            }
            
            print("✅ Created test session: \(session.id)")
            return session
        }
    
    func uploadResponse(
        sessionId: String,
        questionId: String,
        audioURL: URL,
        part: Int,
        order: Int
    ) async throws {
        // OLD WAV FORMAT (COMMENTED OUT)
        // // 1. Generate unique filename with .wav extension
        // let filename = "\(sessionId)_part\(part)_q\(order).wav"
        // let storagePath = "responses/\(filename)"

        // NEW M4A FORMAT
        // 1. Generate unique filename with .m4a extension
        let filename = "\(sessionId)_part\(part)_q\(order).m4a"
        let storagePath = "responses/\(filename)"

        let audioData = try Data(contentsOf: audioURL)
        let fileSizeMB = Double(audioData.count) / (1024 * 1024)

        print("📊 Audio file size: \(String(format: "%.2f", fileSizeMB)) MB (\(audioData.count) bytes)")

        // 3. Check file size limits (M4A files are smaller due to compression)
        // let maxSizeMB: Double = 25.0  // Increased from 10MB to 25MB for WAV files (OLD)
        let maxSizeMB: Double = 10.0  // 10MB should be sufficient for M4A compressed audio
        guard fileSizeMB <= maxSizeMB else {
            print("❌ Audio file too large: \(String(format: "%.2f", fileSizeMB))MB > \(maxSizeMB)MB")
            throw SupabaseError.fileTooLarge(fileSizeMB)
        }

        // 4. Upload to Supabase Storage with correct content type
        do {
            // print("📤 Uploading WAV audio file: \(storagePath)") // OLD WAV FORMAT
            print("📤 Uploading M4A audio file: \(storagePath)")

            try await supabase.storage
                .from("audio-responses")
                .upload(
                    path: storagePath,
                    file: audioData,
                    options: FileOptions(
                        // contentType: "audio/wav",  // OLD WAV FORMAT
                        contentType: "audio/mp4",     // M4A uses audio/mp4 MIME type
                        upsert: true  // Allow overwrite if exists
                    )
                )

            // print("✅ Uploaded WAV audio: \(storagePath) (\(String(format: "%.2f", fileSizeMB)) MB)") // OLD
            print("✅ Uploaded M4A audio: \(storagePath) (\(String(format: "%.2f", fileSizeMB)) MB)")

        } catch {
            print("❌ Storage upload failed: \(error)")

            // More specific error handling
            if let storageError = error as? StorageError {
                if storageError.message.contains("Bucket not found") == true {
                    throw SupabaseError.bucketNotFound
                }
            }

            throw error
        }
        
        // 5. Create response record in database
        let responseRequest = CreateResponseRequest(
            test_session_id: sessionId,
            question_id: questionId,
            audio_file_path: storagePath
        )
        
        do {
            try await supabase
                .from("responses")
                .upsert(responseRequest, onConflict: "test_session_id,question_id")
                .execute()
            
            print("✅ Created response record for question: \(questionId)")
            
        } catch {
            print("❌ Database insert failed: \(error)")
            
            // Clean up uploaded file if database insert fails
            try? await supabase.storage
                .from("audio-responses")
                .remove(paths: [storagePath])
            
            throw error
        }
    }
    
    
    /// Check if session is queued for processing
    func checkSessionStatus(sessionId: String) async throws -> String {
        let response: SessionStatusResponse = try await supabase
            .from("test_sessions")
            .select("status, all_responses_uploaded")
            .eq("id", value: sessionId)
            .single()
            .execute()
            .value
        
        let allUploaded = response.all_responses_uploaded ?? false
        
        print("📊 Session \(sessionId) status: \(response.status), all uploaded: \(allUploaded)")
        return response.status
    }
    
    /// Get test results when processing is complete
    func getTestResults(sessionId: String) async throws -> TestResults? {
        let response: TestResultsResponse = try await supabase
            .from("test_sessions")
            .select("""
                id, status, overall_band_score, fluency_score, pronunciation_score,
                grammar_score, vocabulary_score, completed_at
            """)
            .eq("id", value: sessionId)
            .single()
            .execute()
            .value
        
        guard response.status == "evaluated" else {
            return nil // Still processing
        }
        
        // Get individual response scores
        let responsesResponse: [ResponseScoreResult] = try await supabase
            .from("responses")
            .select("transcript, fluency_score, pronunciation_score, processing_order")
            .eq("test_session_id", value: sessionId)
            .order("processing_order", ascending: true)
            .execute()
            .value
        
        let responses = responsesResponse.map { ResponseResult(
            transcript: $0.transcript ?? "",
            fluencyScore: Double($0.fluency_score ?? "0") ?? 0,
            pronunciationScore: Double($0.pronunciation_score ?? "0") ?? 0,
            processingOrder: $0.processing_order ?? 0
        )}
        
        return TestResults(
            sessionId: sessionId,
            overallBandScore: Double(response.overall_band_score ?? "0") ?? 0,
            fluencyScore: Double(response.fluency_score ?? "0") ?? 0,
            pronunciationScore: Double(response.pronunciation_score ?? "0") ?? 0,
            grammarScore: Double(response.grammar_score ?? "0") ?? 0,
            vocabularyScore: Double(response.vocabulary_score ?? "0") ?? 0,
            completedAt: Date(), // You can parse from response.completed_at if needed
            responses: responses
        )
    }
    
    /// Mark session as completed and trigger evaluation directly
    func markSessionAsCompleted(sessionId: String) async throws {
        print("🔄 Marking session as completed: \(sessionId)")
        
        let updateData = UpdateSessionRequest(
            status: "completed",
            all_responses_uploaded: true,
            completed_at: Date().toISOString()
        )
        
        do {
            try await supabase
                .from("test_sessions")
                .update(updateData)
                .eq("id", value: sessionId)
                .execute()
            
            print("✅ Session marked as completed: \(sessionId)")
            
            // Directly call edge function to trigger evaluation
            try await triggerEvaluation(sessionId: sessionId)
            
        } catch {
            print("❌ Failed to mark session as completed: \(error)")
            throw error
        }
    }
    
    /// Directly call the evaluate-session edge function
    private func triggerEvaluation(sessionId: String) async throws {
        print("🚀 Triggering evaluation for session: \(sessionId)")
        
        guard let currentUser = try? await supabase.auth.user() else {
            throw SupabaseError.noUser
        }
        
        let payload = EvaluationTriggerRequest(
            session_id: sessionId,
            user_id: currentUser.id.uuidString,
            template_id: "550e8400-e29b-41d4-a716-446655440000",
            triggered_at: Date().toISOString()
        )
        
        do {
            try await supabase.functions
                .invoke("evaluate-session", options: FunctionInvokeOptions(
                    body: payload
                ))
            
            print("✅ Evaluation triggered successfully")
            
        } catch {
            print("❌ Failed to trigger evaluation: \(error)")
            // Don't throw here - evaluation might still work via trigger
            // Just log the error
        }
    }
    
    /// Poll for results until processing is complete
    func waitForResults(sessionId: String) async throws -> TestResults {
        print("🔄 Waiting for results for session: \(sessionId)")
        
        var attempts = 0
        let maxAttempts = 30 // 5 minutes max wait
        
        while attempts < maxAttempts {
            if let results = try await getTestResults(sessionId: sessionId) {
                print("✅ Results ready for session: \(sessionId)")
                return results
            }
            
            print("⏳ Still processing... attempt \(attempts + 1)/\(maxAttempts)")
            try await Task.sleep(nanoseconds: 10_000_000_000) // Wait 10 seconds
            attempts += 1
        }
        
        throw SupabaseError.processingTimeout
    }
}


enum SupabaseError: LocalizedError {
    case noUser
    case processingTimeout
    case sessionNotFound
    case fileTooLarge(Double)  // MB size
    case bucketNotFound
    
    var errorDescription: String? {
        switch self {
        case .noUser:
            return "No authenticated user found"
        case .processingTimeout:
            return "Processing took too long. Please try again later."
        case .sessionNotFound:
            return "Test session not found"
        case .fileTooLarge(let sizeMB):
            return "Audio file too large (\(String(format: "%.1f", sizeMB))MB). Please record shorter responses."
        case .bucketNotFound:
            return "Storage bucket not found. Please contact support."
        }
    }
}

// MARK: - Extensions
extension Date {
    func toISOString() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
