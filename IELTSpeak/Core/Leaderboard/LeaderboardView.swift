//import SwiftUI
//
//struct LeaderboardView: View {
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Header with Eiffel Tower
//                headerSection
//                
//                // Days Streak Section
//                daysStreakSection
//                
//                // Practice Time Section
//                practiceTimeSection
//                
//                // Statistics Cards
//                statisticsSection
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//        }
//        .background(Color(UIColor.systemGroupedBackground))
//        .ignoresSafeArea(edges: .top)
//    }
//    
//    private var headerSection: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color.blue.opacity(0.8),
//                            Color.blue.opacity(0.6)
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .frame(height: 200)
//            
//            VStack {
//                // Clouds
//                HStack {
//                    Circle()
//                        .fill(Color.white.opacity(0.3))
//                        .frame(width: 40, height: 40)
//                        .offset(x: -20, y: -20)
//                    
//                    Spacer()
//                    
//                    Circle()
//                        .fill(Color.white.opacity(0.2))
//                        .frame(width: 25, height: 25)
//                        .offset(x: 10, y: -30)
//                    
//                    Circle()
//                        .fill(Color.white.opacity(0.25))
//                        .frame(width: 35, height: 35)
//                        .offset(x: -5, y: -10)
//                }
//                .padding(.horizontal, 30)
//                
//                // Eiffel Tower
//                VStack(spacing: 0) {
//                    Rectangle()
//                        .fill(Color.orange)
//                        .frame(width: 4, height: 20)
//                    
//                    Rectangle()
//                        .fill(Color.orange.opacity(0.8))
//                        .frame(width: 8, height: 3)
//                    
//                    VStack(spacing: 2) {
//                        Rectangle()
//                            .fill(Color.orange)
//                            .frame(width: 50, height: 30)
//                        
//                        Rectangle()
//                            .fill(Color.orange.opacity(0.9))
//                            .frame(width: 60, height: 4)
//                        
//                        Rectangle()
//                            .fill(Color.orange)
//                            .frame(width: 70, height: 40)
//                        
//                        Rectangle()
//                            .fill(Color.orange.opacity(0.9))
//                            .frame(width: 80, height: 4)
//                        
//                        Rectangle()
//                            .fill(Color.orange)
//                            .frame(width: 90, height: 50)
//                    }
//                }
//                .offset(y: 10)
//                
//                // City silhouette
//                HStack(spacing: 5) {
//                    Rectangle()
//                        .fill(Color.white.opacity(0.2))
//                        .frame(width: 30, height: 40)
//                    
//                    Rectangle()
//                        .fill(Color.white.opacity(0.15))
//                        .frame(width: 25, height: 60)
//                    
//                    Spacer()
//                    
//                    Rectangle()
//                        .fill(Color.white.opacity(0.2))
//                        .frame(width: 35, height: 50)
//                    
//                    Rectangle()
//                        .fill(Color.white.opacity(0.1))
//                        .frame(width: 40, height: 70)
//                    
//                    Rectangle()
//                        .fill(Color.white.opacity(0.15))
//                        .frame(width: 20, height: 45)
//                }
//                .padding(.horizontal, 30)
//                .offset(y: 20)
//            }
//        }
//    }
//    
//    private var daysStreakSection: some View {
//        VStack(spacing: 15) {
//            HStack {
//                Circle()
//                    .fill(Color.orange)
//                    .frame(width: 40, height: 40)
//                    .overlay(
//                        Image(systemName: "flame.fill")
//                            .foregroundColor(.white)
//                            .font(.system(size: 20))
//                    )
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Days")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    
//                    Text("Streak")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//            }
//            
//            // Days of the week
//            HStack(spacing: 15) {
//                ForEach(0..<7) { index in
//                    VStack(spacing: 8) {
//                        Circle()
//                            .fill(index == 0 ? Color.orange : Color.gray.opacity(0.2))
//                            .frame(width: 35, height: 35)
//                            .overlay(
//                                Image(systemName: index == 0 ? "checkmark" : "")
//                                    .foregroundColor(.white)
//                                    .font(.system(size: 14, weight: .bold))
//                            )
//                        
//                        Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
//                            .font(.caption)
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//        }
//        .padding(20)
//        .background(Color.white)
//        .cornerRadius(15)
//    }
//    
//    private var practiceTimeSection: some View {
//        VStack(spacing: 15) {
//            HStack {
//                Circle()
//                    .fill(Color.blue.opacity(0.2))
//                    .frame(width: 50, height: 50)
//                    .overlay(
//                        Image(systemName: "clock")
//                            .foregroundColor(.blue)
//                            .font(.system(size: 24))
//                    )
//                
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("5m6s")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    
//                    Text("Practicing French")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                }
//                
//                Spacer()
//            }
//            
//            // Certificate progress
//            HStack(spacing: 15) {
//                Rectangle()
//                    .fill(Color.blue.opacity(0.1))
//                    .frame(width: 60, height: 45)
//                    .cornerRadius(8)
//                    .overlay(
//                        VStack {
//                            Rectangle()
//                                .fill(Color.blue)
//                                .frame(width: 35, height: 25)
//                                .cornerRadius(4)
//                            
//                            Circle()
//                                .fill(Color.red)
//                                .frame(width: 12, height: 12)
//                                .offset(y: -8)
//                        }
//                    )
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Certificate #1")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                    
//                    Text("54m54s remaining")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                    
//                    ProgressView(value: 0.3)
//                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
//                        .frame(height: 4)
//                }
//                
//                Spacer()
//                
//                Circle()
//                    .fill(Color.blue)
//                    .frame(width: 35, height: 35)
//                    .overlay(
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.white)
//                            .font(.system(size: 16, weight: .semibold))
//                    )
//            }
//        }
//        .padding(20)
//        .background(Color.blue.opacity(0.05))
//        .cornerRadius(15)
//    }
//    
//    private var statisticsSection: some View {
//        VStack(spacing: 15) {
//            // Words Spoken
//            statisticCard(
//                icon: "textformat.abc",
//                iconColor: .green,
//                iconBackground: Color.green.opacity(0.1),
//                title: "52",
//                subtitle: "Words Spoken"
//            )
//            
//            // Sentences Spoken
//            statisticCard(
//                icon: "text.quote",
//                iconColor: .yellow,
//                iconBackground: Color.yellow.opacity(0.1),
//                title: "29",
//                subtitle: "Sentences Spoken"
//            )
//            
//            // Stars Conquered
//            statisticCard(
//                icon: "star.fill",
//                iconColor: .pink,
//                iconBackground: Color.pink.opacity(0.1),
//                title: "3",
//                subtitle: "Stars Conquered"
//            )
//            
//            // Days Practicing
//            statisticCard(
//                icon: "calendar",
//                iconColor: .purple,
//                iconBackground: Color.purple.opacity(0.1),
//                title: "2",
//                subtitle: "Days Practicing"
//            )
//            
//            // Longest Streak
//            statisticCard(
//                icon: "clock.arrow.circlepath",
//                iconColor: .indigo,
//                iconBackground: Color.indigo.opacity(0.1),
//                title: "1",
//                subtitle: "Longest Streak"
//            )
//        }
//    }
//    
//    private func statisticCard(icon: String, iconColor: Color, iconBackground: Color, title: String, subtitle: String) -> some View {
//        HStack(spacing: 15) {
//            Circle()
//                .fill(iconBackground)
//                .frame(width: 50, height: 50)
//                .overlay(
//                    Image(systemName: icon)
//                        .foregroundColor(iconColor)
//                        .font(.system(size: 20))
//                )
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(title)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                
//                Text(subtitle)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//        }
//        .padding(20)
//        .background(Color.white)
//        .cornerRadius(15)
//    }
//}
//
//struct LeaderboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeaderboardView()
//    }
//}



import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                daysStreakSection
                
                // Practice Time
                HStack {
                    Label("5m6s", systemImage: "bubble.left")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("Practicing Speaking")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Certificate Progress
                HStack {
                    VStack(alignment: .leading) {
                        Text("Certificate #1")
                            .font(.headline)
                        Text("54m54s remaining")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ProgressView(value: 5.1, total: 60)
                            .accentColor(.blue)
                    }
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Stats Section
                VStack(spacing: 16) {
                    statRow(icon: "textformat.abc", value: "52", label: "Words Spoken", color: .mint)
                    statRow(icon: "text.bubble", value: "29", label: "Sentences Spoken", color: .yellow)
                    statRow(icon: "star.fill", value: "3", label: "Stars Conquered", color: .pink)
                    statRow(icon: "calendar", value: "2", label: "Days Practicing", color: .purple)
                    statRow(icon: "flame", value: "1", label: "Longest Streak", color: .purple)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
    
    private var daysStreakSection: some View {
        VStack(spacing: 15) {
            HStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "flame.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Days")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text("Streak")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Days of the week
            HStack(spacing: 15) {
                ForEach(0..<7) { index in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(index == 0 ? Color.orange : Color.gray.opacity(0.2))
                            .frame(width: 35, height: 35)
                            .overlay(
                                Image(systemName: index == 0 ? "checkmark" : "multiply")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .black))
                            )
                        
                        Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(.orange.opacity(0.2))
            .cornerRadius(12)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(15)
    }
    
    @ViewBuilder
    func statRow(icon: String, value: String, label: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).foregroundColor(color))
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }
}

#Preview {
    LeaderboardView()
}
