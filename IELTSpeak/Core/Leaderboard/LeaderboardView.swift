import SwiftUI
import Supabase

// MARK: - Progress Data Model
struct ProgressData {
    var totalTestsTaken: Int = 0
    var completedTests: Int = 0
    var totalSpeakingSeconds: Int = 0
    var starsEarned: Int = 0
    var daysActive: Int = 0
    var currentStreak: Int = 0
    var activeDaysThisWeek: Set<Int> = [] // 1=Sun..7=Sat
    var todayTestsTaken: Int = 0
    var dailyGoalTarget: Int = 1
    var vocabularyLearned: Int = 0
    var totalVocabulary: Int = 0
    var idiomsLearned: Int = 0
    var totalIdioms: Int = 0
    var phrasalVerbsLearned: Int = 0
    var totalPhrasalVerbs: Int = 0

    var totalSpeakingMinutes: Int {
        totalSpeakingSeconds / 60
    }

    var dailyGoalProgress: Double {
        guard dailyGoalTarget > 0 else { return 0 }
        return min(Double(todayTestsTaken) / Double(dailyGoalTarget), 1.0)
    }
}

// MARK: - Progress ViewModel
@MainActor
class ProgressViewModel: ObservableObject {
    @Published var data = ProgressData()
    @Published var isLoading = false

    func loadProgress() async {
        isLoading = true
        defer { isLoading = false }

        // Load daily goal from UserDefaults
        let goalString = UserDefaults.standard.string(forKey: "dailyPracticeGoal") ?? "regular"
        data.dailyGoalTarget = dailyGoalCount(for: goalString)

        // Load lesson progress locally
        loadLessonProgress()

        // Load backend data
        do {
            let user = try await supabase.auth.user()
            let userId = user.id.uuidString

            try await loadTestSessionData(userId: userId)
        } catch {
            print("Progress: Not authenticated or failed to load: \(error.localizedDescription)")
        }
    }

    private func loadTestSessionData(userId: String) async throws {
        // Fetch all sessions for user
        struct SessionRow: Decodable {
            let id: String
            let status: String
            let started_at: String?
            let completed_at: String?
            let overall_band_score: String?
        }

        let sessions: [SessionRow] = try await supabase
            .from("test_sessions")
            .select("id, status, started_at, completed_at, overall_band_score")
            .eq("user_id", value: userId)
            .execute()
            .value

        data.totalTestsTaken = sessions.count
        data.completedTests = sessions.filter { $0.status == "completed" || $0.status == "evaluated" }.count

        // Stars: count evaluated sessions with band >= 7
        data.starsEarned = sessions.compactMap { session -> Double? in
            guard let scoreStr = session.overall_band_score else { return nil }
            return Double(scoreStr)
        }.filter { $0 >= 7.0 }.count

        // Parse dates for streak and active days
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallbackFormatter = ISO8601DateFormatter()
        fallbackFormatter.formatOptions = [.withInternetDateTime]

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var activeDates: Set<Date> = []
        for session in sessions {
            guard let dateStr = session.started_at else { continue }
            if let date = formatter.date(from: dateStr) ?? fallbackFormatter.date(from: dateStr) {
                activeDates.insert(calendar.startOfDay(for: date))
            }
        }

        data.daysActive = activeDates.count

        // This week's active days (weekday: 1=Sun, 7=Sat)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        data.activeDaysThisWeek = Set(
            activeDates
                .filter { $0 >= startOfWeek && $0 <= today }
                .map { calendar.component(.weekday, from: $0) }
        )

        // Streak calculation
        data.currentStreak = calculateStreak(activeDates: activeDates, from: today, calendar: calendar)

        // Today's tests
        data.todayTestsTaken = sessions.filter { session in
            guard let dateStr = session.started_at,
                  let date = formatter.date(from: dateStr) ?? fallbackFormatter.date(from: dateStr)
            else { return false }
            return calendar.isDateInToday(date)
        }.count

        // Fetch total speaking time from responses
        struct DurationRow: Decodable {
            let duration_seconds: Int?
        }

        let sessionIds = sessions.map { $0.id }
        if !sessionIds.isEmpty {
            let responses: [DurationRow] = try await supabase
                .from("responses")
                .select("duration_seconds")
                .in("test_session_id", values: sessionIds)
                .execute()
                .value

            data.totalSpeakingSeconds = responses.compactMap(\.duration_seconds).reduce(0, +)
        }
    }

    private func calculateStreak(activeDates: Set<Date>, from today: Date, calendar: Calendar) -> Int {
        var streak = 0
        var checkDate = today

        // If today isn't active, start from yesterday
        if !activeDates.contains(checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            if !activeDates.contains(checkDate) {
                return 0
            }
        }

        while activeDates.contains(checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    private func loadLessonProgress() {
        let manager = LessonDataManager.shared
        guard let progress = manager.userProgress else { return }

        // Total items from view model data
        data.totalVocabulary = manager.newVocabularyItems.count
        data.totalIdioms = manager.realIdiomsSubcategories.reduce(0) { $0 + $1.itemCount }
        data.totalPhrasalVerbs = manager.realPhrasalVerbsSubcategories.reduce(0) { $0 + $1.itemCount }

        // Use category progress to estimate learned counts
        // Category IDs are defined in lesson_data.json
        for (catId, catProgress) in progress.categoryProgress {
            let learned = Int(catProgress.overallProgress * Double(totalForCategory(catId)))
            let name = catId.lowercased()
            if name.contains("idiom") {
                data.idiomsLearned = learned
            } else if name.contains("phrasal") {
                data.phrasalVerbsLearned = learned
            } else if name.contains("vocab") {
                data.vocabularyLearned = learned
            }
        }
    }

    private func totalForCategory(_ catId: String) -> Int {
        let name = catId.lowercased()
        if name.contains("idiom") { return data.totalIdioms }
        if name.contains("phrasal") { return data.totalPhrasalVerbs }
        if name.contains("vocab") { return data.totalVocabulary }
        return 0
    }

    private func dailyGoalCount(for goal: String) -> Int {
        switch goal {
        case "casual": return 1
        case "regular": return 2
        case "serious": return 3
        case "intense": return 4
        default: return 1
        }
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @StateObject private var viewModel = ProgressViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                streakCard

                practiceCard

                statsGrid

                milestonesSection
            }
            .padding(.bottom, 100)
        }
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        .task {
            await viewModel.loadProgress()
        }
        .refreshable {
            await viewModel.loadProgress()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("Your Progress")
                .font(.custom("Fredoka-Bold", size: 28))
                .foregroundColor(.primary)

            Text("Keep going, you're doing great!")
                .font(.custom("Fredoka-Medium", size: 15))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    // MARK: - Streak Card
    private var streakCard: some View {
        let d = viewModel.data
        return VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.warningOrange.opacity(0.3), Color.warningOrange.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: "flame.fill")
                            .foregroundColor(.warningOrange)
                            .font(.system(size: 22))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(d.currentStreak) Day Streak")
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundColor(.primary)

                        Text(d.currentStreak > 0 ? "Practice daily to keep it alive!" : "Start practicing to build a streak!")
                            .font(.custom("Fredoka-Medium", size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            // Days of the week
            HStack(spacing: 0) {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                    let weekday = index + 1 // 1=Sun, 7=Sat
                    let isActive = d.activeDaysThisWeek.contains(weekday)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(isActive ? Color.brandGreen : Color.gray.opacity(0.12))
                                .frame(width: 38, height: 38)

                            if isActive {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Text(day)
                            .font(.custom("Fredoka-Medium", size: 13))
                            .foregroundColor(isActive ? .brandGreen : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color.warningOrange.opacity(0.06))
            .cornerRadius(16)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 20)
    }

    // MARK: - Speaking Practice Card (Daily Goal)
    private var practiceCard: some View {
        let d = viewModel.data

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.12))
                    .frame(width: 52, height: 52)

                Circle()
                    .trim(from: 0, to: d.dailyGoalProgress)
                    .stroke(Color.brandGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: d.dailyGoalProgress)

                Image(systemName: "mic.fill")
                    .foregroundColor(.brandGreen)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Speaking Practice")
                    .font(.custom("Fredoka-SemiBold", size: 17))
                    .foregroundColor(.primary)

                Text("\(d.todayTestsTaken)/\(d.dailyGoalTarget) tests today")
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if d.todayTestsTaken >= d.dailyGoalTarget {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.brandGreen)
                    .font(.system(size: 22))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.5))
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 20)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        let d = viewModel.data

        return VStack(spacing: 12) {
            HStack(spacing: 12) {
                LeaderboardStatCard(
                    icon: "doc.text.fill",
                    value: "\(d.completedTests)/\(d.totalTestsTaken)",
                    label: "Tests Completed",
                    color: .lightBlue
                )

                LeaderboardStatCard(
                    icon: "clock.fill",
                    value: formatSpeakingTime(d.totalSpeakingMinutes),
                    label: "Total Speaking",
                    color: .rewardYellow
                )
            }

            HStack(spacing: 12) {
                LeaderboardStatCard(
                    icon: "star.fill",
                    value: "\(d.starsEarned)",
                    label: "Stars Earned",
                    color: .warningOrange
                )

                LeaderboardStatCard(
                    icon: "calendar",
                    value: "\(d.daysActive)",
                    label: "Days Active",
                    color: .brandGreen
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Milestones
    private var milestonesSection: some View {
        let d = viewModel.data

        return VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.custom("Fredoka-SemiBold", size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)

            VStack(spacing: 10) {
                MilestoneRow(
                    icon: "flame.fill",
                    title: "7-Day Streak",
                    subtitle: "Practice 7 days in a row",
                    progress: Double(min(d.currentStreak, 7)) / 7.0,
                    current: min(d.currentStreak, 7),
                    target: 7,
                    color: .warningOrange
                )

                MilestoneRow(
                    icon: "doc.text.fill",
                    title: "Test Taker",
                    subtitle: "Complete 10 speaking tests",
                    progress: Double(min(d.completedTests, 10)) / 10.0,
                    current: d.completedTests,
                    target: 10,
                    color: .lightBlue
                )

                MilestoneRow(
                    icon: "star.fill",
                    title: "Star Collector",
                    subtitle: "Earn 10 stars (Band 7+)",
                    progress: Double(min(d.starsEarned, 10)) / 10.0,
                    current: d.starsEarned,
                    target: 10,
                    color: .rewardYellow
                )

                MilestoneRow(
                    icon: "clock.fill",
                    title: "Dedicated Speaker",
                    subtitle: "Practice for 2 hours total",
                    progress: Double(min(d.totalSpeakingMinutes, 120)) / 120.0,
                    current: d.totalSpeakingMinutes,
                    target: 120,
                    color: .brandGreen,
                    unit: "min"
                )

                MilestoneRow(
                    icon: "character.book.closed.fill",
                    title: "Vocabulary Builder",
                    subtitle: "Learn 50 vocabulary words",
                    progress: d.totalVocabulary > 0 ? Double(min(d.vocabularyLearned, 50)) / 50.0 : 0,
                    current: d.vocabularyLearned,
                    target: 50,
                    color: .infoBlue
                )

                MilestoneRow(
                    icon: "text.quote",
                    title: "Idiom Expert",
                    subtitle: "Learn 30 idioms",
                    progress: d.totalIdioms > 0 ? Double(min(d.idiomsLearned, 30)) / 30.0 : 0,
                    current: d.idiomsLearned,
                    target: 30,
                    color: Color(red: 156/255, green: 39/255, blue: 176/255)
                )

                MilestoneRow(
                    icon: "textformat.alt",
                    title: "Phrasal Verb Pro",
                    subtitle: "Learn 30 phrasal verbs",
                    progress: d.totalPhrasalVerbs > 0 ? Double(min(d.phrasalVerbsLearned, 30)) / 30.0 : 0,
                    current: d.phrasalVerbsLearned,
                    target: 30,
                    color: Color(red: 0/255, green: 150/255, blue: 136/255)
                )
            }
        }
        .padding(.horizontal, 20)
    }

    private func formatSpeakingTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = minutes / 60
        let remaining = minutes % 60
        if remaining == 0 {
            return "\(hours)h"
        }
        return "\(hours)h \(remaining)m"
    }
}

// MARK: - Stat Card
struct LeaderboardStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.custom("Fredoka-Bold", size: 24))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Milestone Row
struct MilestoneRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let progress: Double
    let current: Int
    let target: Int
    let color: Color
    var unit: String = ""

    var isCompleted: Bool { current >= target }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isCompleted ? color : color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: isCompleted ? "checkmark" : icon)
                    .foregroundColor(isCompleted ? .white : color)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.custom("Fredoka-SemiBold", size: 15))
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(current)\(unit)/\(target)\(unit)")
                        .font(.custom("Fredoka-Medium", size: 13))
                        .foregroundColor(isCompleted ? color : .secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.opacity(0.12))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geometry.size.width * min(progress, 1.0), height: 6)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(18)
    }
}

#Preview {
    LeaderboardView()
}
