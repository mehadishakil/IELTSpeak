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

struct CreateResponseWithR2Request: Codable {
    let test_session_id: String
    let question_id: String
    let r2_key: String
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
            
            await MainActor.run {
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
        let audioData = try Data(contentsOf: audioURL)
        let fileSizeMB = Double(audioData.count) / (1024 * 1024)

        print("📊 Audio file size: \(String(format: "%.2f", fileSizeMB)) MB (\(audioData.count) bytes)")

        let maxSizeMB: Double = 10.0
        guard fileSizeMB <= maxSizeMB else {
            print("❌ Audio file too large: \(String(format: "%.2f", fileSizeMB))MB > \(maxSizeMB)MB")
            throw SupabaseError.fileTooLarge(fileSizeMB)
        }

        // Try R2 upload via Go backend first, fall back to Supabase Storage
        do {
            try await uploadToR2(
                sessionId: sessionId,
                questionId: questionId,
                audioData: audioData,
                part: part,
                order: order
            )
            return
        } catch {
            print("⚠️ R2 upload failed, falling back to Supabase Storage: \(error.localizedDescription)")
        }

        // Fallback: Upload to Supabase Storage (legacy path)
        try await uploadToSupabaseStorage(
            sessionId: sessionId,
            questionId: questionId,
            audioData: audioData,
            part: part,
            order: order
        )
    }

    /// Upload audio to R2 via Go backend pre-signed URL.
    private func uploadToR2(
        sessionId: String,
        questionId: String,
        audioData: Data,
        part: Int,
        order: Int
    ) async throws {
        let currentUser = try await supabase.auth.user()
        let userID = currentUser.id.uuidString

        print("📤 Uploading to R2 via backend...")

        // 1. Get pre-signed upload URL from Go backend
        let presigned = try await BackendService.shared.generateUploadURL(
            userID: userID,
            testID: sessionId,
            partType: "part\(part)",
            questionID: questionId,
            fileExtension: ".m4a"
        )

        print("📎 Got pre-signed URL, R2 key: \(presigned.r2_key)")

        // 2. Upload directly to R2
        try await BackendService.shared.uploadToR2(
            presignedURL: presigned.upload_url,
            audioData: audioData,
            contentType: "audio/mp4"
        )

        print("✅ Uploaded to R2: \(presigned.r2_key)")

        // 3. Create response record in Supabase DB with r2_key
        let responseRequest = CreateResponseWithR2Request(
            test_session_id: sessionId,
            question_id: questionId,
            r2_key: presigned.r2_key
        )

        try await supabase
            .from("responses")
            .upsert(responseRequest, onConflict: "test_session_id,question_id")
            .execute()

        print("✅ Created response record with R2 key for question: \(questionId)")

        // 4. Notify backend that upload is complete
        try await BackendService.shared.notifyUploadComplete(
            responseID: "",
            r2Key: presigned.r2_key,
            testSessionID: sessionId,
            userID: userID,
            templateID: "550e8400-e29b-41d4-a716-446655440000",
            questionID: questionId,
            triggerEvaluation: false
        )
    }

    /// Legacy upload to Supabase Storage (fallback when backend is unavailable).
    private func uploadToSupabaseStorage(
        sessionId: String,
        questionId: String,
        audioData: Data,
        part: Int,
        order: Int
    ) async throws {
        let filename = "\(sessionId)_part\(part)_q\(order).m4a"
        let storagePath = "responses/\(filename)"
        let fileSizeMB = Double(audioData.count) / (1024 * 1024)

        print("📤 Uploading M4A to Supabase Storage (fallback): \(storagePath)")

        do {
            try await supabase.storage
                .from("audio-responses")
                .upload(
                    path: storagePath,
                    file: audioData,
                    options: FileOptions(
                        contentType: "audio/mp4",
                        upsert: true
                    )
                )

            print("✅ Uploaded M4A audio: \(storagePath) (\(String(format: "%.2f", fileSizeMB)) MB)")

        } catch {
            print("❌ Storage upload failed: \(error)")
            if let storageError = error as? StorageError {
                if storageError.message.contains("Bucket not found") == true {
                    throw SupabaseError.bucketNotFound
                }
            }
            throw error
        }

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

            // Try triggering evaluation via Go backend's upload-complete endpoint
            // (this directly enqueues an Asynq task, faster than edge function relay)
            do {
                let currentUser = try await supabase.auth.user()
                try await BackendService.shared.notifyUploadComplete(
                    responseID: "",
                    r2Key: "",
                    testSessionID: sessionId,
                    userID: currentUser.id.uuidString,
                    templateID: "550e8400-e29b-41d4-a716-446655440000",
                    questionID: "",
                    triggerEvaluation: true
                )
                print("✅ Evaluation triggered via Go backend")
            } catch {
                print("⚠️ Go backend trigger failed, falling back to edge function: \(error.localizedDescription)")
                try await triggerEvaluation(sessionId: sessionId)
            }

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
