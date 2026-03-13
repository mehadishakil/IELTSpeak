import Foundation

// MARK: - Backend Service for Go Evaluation Server + R2 Storage

/// Communicates with the Go backend for R2 uploads, question fetching, and evaluation.
/// Uses Supabase JWT token for authentication.
class BackendService {
    static let shared = BackendService()

    // TODO: Update this URL when deploying to production
    private let baseURL = "http://localhost:8080"

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }

    // MARK: - Auth Token

    /// Gets the current Supabase access token for authenticating with the Go backend.
    private func getAuthToken() async throws -> String {
        let session = try await supabase.auth.session
        return session.accessToken
    }

    // MARK: - Test Questions (Task 1)

    /// Fetches test questions with R2 pre-signed audio download URLs from the Go backend.
    func fetchTestQuestions(templateId: String = "550e8400-e29b-41d4-a716-446655440000") async throws -> [BackendQuestionResponse] {
        let token = try await getAuthToken()

        var components = URLComponents(string: "\(baseURL)/test-questions")!
        components.queryItems = [URLQueryItem(name: "template_id", value: templateId)]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("❌ Backend /test-questions failed: \(httpResponse.statusCode) - \(body)")
            throw BackendError.serverError(httpResponse.statusCode, body)
        }

        let result = try JSONDecoder().decode(TestQuestionsAPIResponse.self, from: data)
        return result.questions
    }

    /// Downloads audio data from a pre-signed URL.
    func downloadAudio(from url: String) async throws -> Data {
        guard let audioURL = URL(string: url) else {
            throw BackendError.invalidURL(url)
        }

        let (data, response) = try await session.data(from: audioURL)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw BackendError.audioDownloadFailed
        }

        return data
    }

    // MARK: - R2 Upload (Task 2)

    /// Requests a pre-signed upload URL from the Go backend for direct-to-R2 upload.
    func generateUploadURL(
        userID: String,
        testID: String,
        partType: String,
        questionID: String,
        fileExtension: String = ".m4a"
    ) async throws -> PresignedUploadResponse {
        let token = try await getAuthToken()

        let url = URL(string: "\(baseURL)/generate-upload-url")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GenerateUploadURLRequest(
            user_id: userID,
            test_id: testID,
            part_type: partType,
            question_id: questionID,
            file_extension: fileExtension
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            if httpResponse.statusCode == 403 {
                throw BackendError.quotaExceeded
            }
            throw BackendError.serverError(httpResponse.statusCode, responseBody)
        }

        return try JSONDecoder().decode(PresignedUploadResponse.self, from: data)
    }

    /// Uploads audio data directly to R2 using a pre-signed PUT URL.
    func uploadToR2(presignedURL: String, audioData: Data, contentType: String = "audio/mp4") async throws {
        guard let url = URL(string: presignedURL) else {
            throw BackendError.invalidURL(presignedURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = audioData

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw BackendError.r2UploadFailed(statusCode)
        }
    }

    /// Notifies the backend that an upload to R2 is complete.
    func notifyUploadComplete(
        responseID: String,
        r2Key: String,
        testSessionID: String,
        userID: String,
        templateID: String,
        questionID: String,
        triggerEvaluation: Bool = false
    ) async throws {
        let token = try await getAuthToken()

        let url = URL(string: "\(baseURL)/upload-complete")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UploadCompleteAPIRequest(
            response_id: responseID,
            r2_key: r2Key,
            test_session_id: testSessionID,
            user_id: userID,
            template_id: templateID,
            question_id: questionID,
            trigger_evaluation: triggerEvaluation
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw BackendError.serverError(statusCode, responseBody)
        }
    }
}

// MARK: - API Models

struct TestQuestionsAPIResponse: Decodable {
    let questions: [BackendQuestionResponse]
}

struct BackendQuestionResponse: Decodable {
    let id: String
    let test_template_id: String
    let part_number: Int
    let question_order: Int
    let question_text: String
    let audio_url: String
    let transcript: String?
}

struct GenerateUploadURLRequest: Encodable {
    let user_id: String
    let test_id: String
    let part_type: String
    let question_id: String
    let file_extension: String
}

struct PresignedUploadResponse: Decodable {
    let upload_url: String
    let r2_key: String
    let expires_in: Int
}

struct UploadCompleteAPIRequest: Encodable {
    let response_id: String
    let r2_key: String
    let test_session_id: String
    let user_id: String
    let template_id: String
    let question_id: String
    let trigger_evaluation: Bool
}

// MARK: - Errors

enum BackendError: LocalizedError {
    case invalidResponse
    case invalidURL(String)
    case serverError(Int, String)
    case audioDownloadFailed
    case quotaExceeded
    case r2UploadFailed(Int)
    case noAuthToken

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from backend"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .serverError(let code, let body):
            return "Server error (\(code)): \(body)"
        case .audioDownloadFailed:
            return "Failed to download audio file"
        case .quotaExceeded:
            return "Monthly test limit reached. Upgrade your plan for more tests."
        case .r2UploadFailed(let code):
            return "Failed to upload audio to storage (HTTP \(code))"
        case .noAuthToken:
            return "No authentication token available"
        }
    }
}
