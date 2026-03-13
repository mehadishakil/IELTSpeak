import SwiftUI
import Supabase

// MARK: - Models

struct FeatureRequest: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let title: String
    let description: String
    let status: String
    let upvoteCount: Int
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case description
        case status
        case upvoteCount = "upvote_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var statusDisplay: String {
        switch status {
        case "pending": return "Pending"
        case "under_review": return "Under Review"
        case "planned": return "Planned"
        case "in_progress": return "In Progress"
        case "completed": return "Completed"
        case "declined": return "Declined"
        default: return status.capitalized
        }
    }

    var statusColor: Color {
        switch status {
        case "pending": return .secondary
        case "under_review": return .warningOrange
        case "planned": return .infoBlue
        case "in_progress": return .errorRed
        case "completed": return .brandGreen
        case "declined": return .textGray
        default: return .secondary
        }
    }
}

struct FeatureRequestVote: Codable {
    let featureRequestId: UUID
    let userId: UUID

    enum CodingKeys: String, CodingKey {
        case featureRequestId = "feature_request_id"
        case userId = "user_id"
    }
}

struct CreateFeatureRequest: Codable {
    let userId: UUID
    let title: String
    let description: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title
        case description
    }
}

// MARK: - ViewModel

@MainActor
class FeatureRequestViewModel: ObservableObject {
    @Published var featureRequests: [FeatureRequest] = []
    @Published var votedRequestIds: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private var currentUserId: UUID?

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await supabase.auth.session.user
            currentUserId = user.id

            // Fetch all feature requests sorted by upvotes
            let requests: [FeatureRequest] = try await supabase
                .from("feature_requests")
                .select()
                .order("upvote_count", ascending: false)
                .execute()
                .value

            featureRequests = requests

            // Fetch user's votes
            let votes: [FeatureRequestVote] = try await supabase
                .from("feature_request_votes")
                .select()
                .eq("user_id", value: user.id)
                .execute()
                .value

            votedRequestIds = Set(votes.map { $0.featureRequestId })

        } catch {
            errorMessage = "Failed to load feature requests"
            showError = true
            debugPrint("Error loading feature requests: \(error)")
        }
    }

    func submitRequest(title: String, description: String) async -> Bool {
        guard let userId = currentUserId else {
            errorMessage = "You must be logged in to submit a feature request"
            showError = true
            return false
        }

        do {
            let newRequest = CreateFeatureRequest(
                userId: userId,
                title: title,
                description: description
            )

            try await supabase
                .from("feature_requests")
                .insert(newRequest)
                .execute()

            await loadData()
            return true
        } catch {
            errorMessage = "Failed to submit feature request"
            showError = true
            debugPrint("Error submitting feature request: \(error)")
            return false
        }
    }

    func toggleVote(for requestId: UUID) async {
        guard let userId = currentUserId else {
            errorMessage = "You must be logged in to vote"
            showError = true
            return
        }

        let isCurrentlyVoted = votedRequestIds.contains(requestId)

        // Optimistic update
        if isCurrentlyVoted {
            votedRequestIds.remove(requestId)
            if let idx = featureRequests.firstIndex(where: { $0.id == requestId }) {
                let r = featureRequests[idx]
                let updated = FeatureRequest(
                    id: r.id, userId: r.userId, title: r.title,
                    description: r.description, status: r.status,
                    upvoteCount: max(r.upvoteCount - 1, 0),
                    createdAt: r.createdAt, updatedAt: r.updatedAt
                )
                featureRequests[idx] = updated
            }
        } else {
            votedRequestIds.insert(requestId)
            if let idx = featureRequests.firstIndex(where: { $0.id == requestId }) {
                let r = featureRequests[idx]
                let updated = FeatureRequest(
                    id: r.id, userId: r.userId, title: r.title,
                    description: r.description, status: r.status,
                    upvoteCount: r.upvoteCount + 1,
                    createdAt: r.createdAt, updatedAt: r.updatedAt
                )
                featureRequests[idx] = updated
            }
        }

        do {
            if isCurrentlyVoted {
                // Remove vote
                try await supabase
                    .from("feature_request_votes")
                    .delete()
                    .eq("feature_request_id", value: requestId)
                    .eq("user_id", value: userId)
                    .execute()

                try await supabase.rpc("decrement_upvote_count", params: ["request_id": requestId])
                    .execute()
            } else {
                // Add vote
                let vote = FeatureRequestVote(featureRequestId: requestId, userId: userId)
                try await supabase
                    .from("feature_request_votes")
                    .insert(vote)
                    .execute()

                try await supabase.rpc("increment_upvote_count", params: ["request_id": requestId])
                    .execute()
            }
        } catch {
            // Revert optimistic update on failure
            if isCurrentlyVoted {
                votedRequestIds.insert(requestId)
            } else {
                votedRequestIds.remove(requestId)
            }
            await loadData()
            debugPrint("Error toggling vote: \(error)")
        }
    }

    func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let days = Int(interval / 86400)
        if days == 0 { return "Today" }
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days)d ago" }
        if days < 30 { return "\(days / 7)w ago" }
        if days < 365 { return "\(days / 30)mo ago" }
        return "\(days / 365)y ago"
    }
}

// MARK: - Feature Request Board View

struct FeedbackBoardView: View {
    @StateObject private var viewModel = FeatureRequestViewModel()
    @State private var showNewRequestSheet = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if viewModel.isLoading && viewModel.featureRequests.isEmpty {
                    loadingView
                } else if viewModel.featureRequests.isEmpty {
                    emptyStateView
                } else {
                    requestListView
                }
            }

            // Floating action button
            Button {
                showNewRequestSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.brandGreen, Color.primaryVariant],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: Color.brandGreen.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle("Request Feature")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
        .sheet(isPresented: $showNewRequestSheet) {
            NewFeatureRequestSheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong")
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading requests...")
                .font(.custom("Fredoka-Regular", size: 16))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lightbulb.fill")
                .font(.system(size: 56))
                .foregroundColor(.rewardYellow)

            Text("No Feature Requests Yet")
                .font(.custom("Fredoka-SemiBold", size: 22))
                .foregroundColor(.primary)

            Text("Be the first to suggest a new feature!\nTap the + button below to get started.")
                .font(.custom("Fredoka-Regular", size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var requestListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.featureRequests) { request in
                    NavigationLink(destination: FeatureRequestDetailView(
                        request: request,
                        isVoted: viewModel.votedRequestIds.contains(request.id),
                        onVote: {
                            Task { await viewModel.toggleVote(for: request.id) }
                        }
                    )) {
                        FeatureRequestCard(
                            request: request,
                            isVoted: viewModel.votedRequestIds.contains(request.id),
                            timeAgo: viewModel.timeAgo(from: request.createdAt),
                            onVote: {
                                Task { await viewModel.toggleVote(for: request.id) }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Feature Request Card

struct FeatureRequestCard: View {
    let request: FeatureRequest
    let isVoted: Bool
    let timeAgo: String
    let onVote: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Main content
            VStack(alignment: .leading, spacing: 8) {
                Text(request.title)
                    .font(.custom("Fredoka-SemiBold", size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(request.description)
                    .font(.custom("Fredoka-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    // Time ago
                    Text(timeAgo)
                        .font(.custom("Fredoka-Regular", size: 12))
                        .foregroundColor(.secondary)

                    // Status badge (always visible)
                    StatusBadge(status: request.statusDisplay, color: request.statusColor)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 8)

            // Upvote button
            Button(action: onVote) {
                VStack(spacing: 4) {
                    Image(systemName: isVoted ? "arrowtriangle.up.fill" : "arrowtriangle.up")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isVoted ? .white : .brandGreen)

                    Text("\(request.upvoteCount)")
                        .font(.custom("Fredoka-SemiBold", size: 14))
                        .foregroundColor(isVoted ? .white : .brandGreen)
                }
                .frame(width: 52, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isVoted
                              ? LinearGradient(colors: [Color.brandGreen, Color.primaryVariant], startPoint: .top, endPoint: .bottom)
                              : LinearGradient(colors: [Color.brandGreen.opacity(0.1), Color.brandGreen.opacity(0.1)], startPoint: .top, endPoint: .bottom)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isVoted ? Color.clear : Color.brandGreen.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String
    let color: Color

    var body: some View {
        Text(status)
            .font(.custom("Fredoka-Medium", size: 11))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.25), lineWidth: 0.5)
            )
    }
}

// MARK: - Feature Request Detail View

struct FeatureRequestDetailView: View {
    let request: FeatureRequest
    let isVoted: Bool
    let onVote: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Status + upvote header
                HStack(alignment: .center) {
                    StatusBadge(status: request.statusDisplay, color: request.statusColor)

                    Spacer()

                    Button(action: onVote) {
                        HStack(spacing: 6) {
                            Image(systemName: isVoted ? "arrowtriangle.up.fill" : "arrowtriangle.up")
                                .font(.system(size: 13, weight: .semibold))
                            Text("\(request.upvoteCount)")
                                .font(.custom("Fredoka-SemiBold", size: 15))
                        }
                        .foregroundColor(isVoted ? .white : .brandGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isVoted
                                      ? LinearGradient(colors: [Color.brandGreen, Color.primaryVariant], startPoint: .leading, endPoint: .trailing)
                                      : LinearGradient(colors: [Color.brandGreen.opacity(0.1), Color.brandGreen.opacity(0.1)], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(isVoted ? Color.clear : Color.brandGreen.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Title
                Text(request.title)
                    .font(.custom("Fredoka-SemiBold", size: 24))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Divider
                Rectangle()
                    .fill(Color(.separator).opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                // Description
                Text(request.description)
                    .font(.custom("Fredoka-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                // Meta info card
                VStack(spacing: 0) {
                    detailRow(icon: "clock", label: "Submitted", value: formattedDate(request.createdAt))

                    Rectangle()
                        .fill(Color(.separator).opacity(0.2))
                        .frame(height: 1)
                        .padding(.leading, 52)

                    detailRow(icon: "arrow.triangle.2.circlepath", label: "Last Updated", value: formattedDate(request.updatedAt))

                    Rectangle()
                        .fill(Color(.separator).opacity(0.2))
                        .frame(height: 1)
                        .padding(.leading, 52)

                    HStack(spacing: 12) {
                        Image(systemName: "flag")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .frame(width: 24)

                        Text("Status")
                            .font(.custom("Fredoka-Regular", size: 14))
                            .foregroundColor(.secondary)

                        Spacer()

                        StatusBadge(status: request.statusDisplay, color: request.statusColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Rectangle()
                        .fill(Color(.separator).opacity(0.2))
                        .frame(height: 1)
                        .padding(.leading, 52)

                    detailRow(icon: "hand.thumbsup", label: "Upvotes", value: "\(request.upvoteCount)")
                }
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.custom("Fredoka-Regular", size: 14))
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.custom("Fredoka-Medium", size: 14))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - New Feature Request Sheet

struct NewFeatureRequestSheet: View {
    @ObservedObject var viewModel: FeatureRequestViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @FocusState private var focusedField: Field?

    enum Field { case title, description }

    private let titleMaxLength = 80
    private let descriptionMaxLength = 500

    private var isValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDesc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty && !trimmedDesc.isEmpty &&
               title.count <= titleMaxLength && description.count <= descriptionMaxLength
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header illustration
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.rewardYellow.opacity(0.2), Color.rewardYellow.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 34))
                                .foregroundColor(.rewardYellow)
                        }

                        Text("Share Your Idea")
                            .font(.custom("Fredoka-SemiBold", size: 22))
                            .foregroundColor(.primary)

                        Text("Help us make IELTSpeak better for everyone")
                            .font(.custom("Fredoka-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Form fields
                    VStack(alignment: .leading, spacing: 20) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Feature Title")
                                    .font(.custom("Fredoka-Medium", size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(title.count)/\(titleMaxLength)")
                                    .font(.custom("Fredoka-Regular", size: 12))
                                    .foregroundColor(title.count > titleMaxLength ? .errorRed : .secondary)
                            }

                            TextField("e.g. Practice with AI conversation partner", text: $title)
                                .font(.custom("Fredoka-Regular", size: 16))
                                .padding(14)
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(12)
                                .focused($focusedField, equals: .title)
                                .onChange(of: title) { _, newValue in
                                    if newValue.count > titleMaxLength {
                                        title = String(newValue.prefix(titleMaxLength))
                                    }
                                }
                        }

                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Description")
                                    .font(.custom("Fredoka-Medium", size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(description.count)/\(descriptionMaxLength)")
                                    .font(.custom("Fredoka-Regular", size: 12))
                                    .foregroundColor(description.count > descriptionMaxLength ? .errorRed : .secondary)
                            }

                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $description)
                                    .font(.custom("Fredoka-Regular", size: 16))
                                    .frame(minHeight: 120)
                                    .padding(10)
                                    .scrollContentBackground(.hidden)
                                    .background(Color(.systemGroupedBackground))
                                    .cornerRadius(12)
                                    .focused($focusedField, equals: .description)
                                    .onChange(of: description) { _, newValue in
                                        if newValue.count > descriptionMaxLength {
                                            description = String(newValue.prefix(descriptionMaxLength))
                                        }
                                    }

                                if description.isEmpty {
                                    Text("Describe how this feature would help your IELTS preparation...")
                                        .font(.custom("Fredoka-Regular", size: 16))
                                        .foregroundColor(.secondary.opacity(0.5))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 18)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    // Submit button
                    Button {
                        submit()
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 16))
                            }
                            Text("Submit Request")
                                .font(.custom("Fredoka-SemiBold", size: 17))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: isValid
                                    ? [Color.brandGreen, Color.primaryVariant]
                                    : [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    .disabled(!isValid || isSubmitting)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemBackground))
            .navigationTitle("New Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Fredoka-Medium", size: 16))
                }
            }
        }
    }

    private func submit() {
        guard isValid else { return }
        isSubmitting = true

        Task {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedDesc = description.trimmingCharacters(in: .whitespacesAndNewlines)

            let success = await viewModel.submitRequest(title: trimmedTitle, description: trimmedDesc)
            isSubmitting = false

            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationStack {
        FeedbackBoardView()
    }
}
