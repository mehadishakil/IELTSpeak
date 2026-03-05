import SwiftUI

struct LeaderboardView: View {
    @State private var selectedTimeframe: Timeframe = .thisWeek

    enum Timeframe: String, CaseIterable {
        case thisWeek = "This Week"
        case allTime = "All Time"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerSection

                // Streak card
                streakCard

                // Practice time card
                practiceTimeCard

                // Stats grid
                statsGrid

                // Milestones
                milestonesSection
            }
            .padding(.bottom, 100)
        }
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
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
        VStack(spacing: 16) {
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
                        Text("1 Day Streak")
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundColor(.primary)

                        Text("Practice daily to keep it alive!")
                            .font(.custom("Fredoka-Medium", size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            // Days of the week
            HStack(spacing: 0) {
                ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(index == 0 ? Color.brandGreen : Color.gray.opacity(0.12))
                                .frame(width: 38, height: 38)

                            if index == 0 {
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
                            .foregroundColor(index == 0 ? .brandGreen : .secondary)
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

    // MARK: - Practice Time Card
    private var practiceTimeCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandGreen.opacity(0.12))
                    .frame(width: 52, height: 52)

                // Progress ring
                Circle()
                    .trim(from: 0, to: 0.45)
                    .stroke(Color.brandGreen, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "mic.fill")
                    .foregroundColor(.brandGreen)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Speaking Practice")
                    .font(.custom("Fredoka-SemiBold", size: 17))
                    .foregroundColor(.primary)

                Text("54 min total practice time")
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal, 20)
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                LeaderboardStatCard(
                    icon: "textformat.abc",
                    value: "52",
                    label: "Words Spoken",
                    color: .lightBlue
                )

                LeaderboardStatCard(
                    icon: "text.bubble.fill",
                    value: "29",
                    label: "Sentences",
                    color: .rewardYellow
                )
            }

            HStack(spacing: 12) {
                LeaderboardStatCard(
                    icon: "star.fill",
                    value: "3",
                    label: "Stars Earned",
                    color: .warningOrange
                )

                LeaderboardStatCard(
                    icon: "calendar",
                    value: "2",
                    label: "Days Active",
                    color: .brandGreen
                )
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.custom("Fredoka-SemiBold", size: 20))
                .foregroundColor(.primary)
                .padding(.horizontal, 4)

            VStack(spacing: 10) {
                MilestoneRow(
                    icon: "flame.fill",
                    title: "7-Day Streak",
                    subtitle: "Practice 7 days in a row",
                    progress: 1.0 / 7.0,
                    current: 1,
                    target: 7,
                    color: .warningOrange
                )

                MilestoneRow(
                    icon: "textformat.abc",
                    title: "Word Master",
                    subtitle: "Speak 100 unique words",
                    progress: 52.0 / 100.0,
                    current: 52,
                    target: 100,
                    color: .lightBlue
                )

                MilestoneRow(
                    icon: "star.fill",
                    title: "Star Collector",
                    subtitle: "Earn 10 stars",
                    progress: 3.0 / 10.0,
                    current: 3,
                    target: 10,
                    color: .rewardYellow
                )

                MilestoneRow(
                    icon: "clock.fill",
                    title: "Dedicated Speaker",
                    subtitle: "Practice for 2 hours total",
                    progress: 54.0 / 120.0,
                    current: 54,
                    target: 120,
                    color: .brandGreen,
                    unit: "min"
                )
            }
        }
        .padding(.horizontal, 20)
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
                    .font(.custom("Fredoka-Bold", size: 28))
                    .foregroundColor(.primary)

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

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .foregroundColor(color)
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
                        .foregroundColor(.secondary)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color.opacity(0.12))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: geometry.size.width * min(progress, 1.0), height: 6)
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
