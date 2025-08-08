import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                daysStreakSection
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Practicing Speaking")
                            .font(.custom("Fredoka-Semibold", size: 20))
                            .foregroundStyle(.primary.opacity(0.75))
                        Text("54m54s total")
                            .font(.custom("Fredoka-Regular", size: 14))
                            .foregroundStyle(.secondary)
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
                    statRow(
                        icon: "textformat.abc",
                        value: "52",
                        label: "Words Spoken",
                        color: .green
                    )
                    statRow(icon: "text.bubble", value: "29", label: "Sentences Spoken", color: .yellow)
                    statRow(icon: "star.fill", value: "3", label: "Stars Conquered", color: .pink)
                    statRow(
                        icon: "calendar",
                        value: "2",
                        label: "Days Practicing",
                        color: .mint
                )
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
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 20))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Days")
                        .font(.custom("Fredoka-Semibold", size: 20))
                        .foregroundStyle(.primary.opacity(0.75))
                    
                    Text("Streak")
                        .font(.custom("Fredoka-Regular", size: 14))
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
                            .font(.custom("Fredoka-Medium", size: 14))
                            .foregroundStyle(.secondary)
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
        HStack(alignment: .top) {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay(Image(systemName: icon).foregroundColor(color))
            
            HStack{
                VStack(alignment: .leading) {
                    Text(value)
                        .font(.custom("Fredoka-Medium", size: 18))
                        .foregroundStyle(.primary.opacity(0.8))
                    Spacer()
                    
                    Text(label)
                        .font(.custom("Fredoka-Medium", size: 16))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(color.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

#Preview {
    LeaderboardView()
}
