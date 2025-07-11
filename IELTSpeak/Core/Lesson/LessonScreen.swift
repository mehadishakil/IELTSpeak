//import SwiftUI
//
//struct LessonScreen: View {
//    @State private var selectedCategory: String? = nil
//    @State private var showDailyLesson = false
//    
//    let categories = [
//        LessonCategory(
//            id: "vocabulary",
//            title: "Vocabulary",
//            description: "Build your word bank with essential IELTS vocabulary",
//            icon: "book.fill",
//            color: Color.blue,
//            progress: 0.75,
//            streak: 5
//        ),
//        LessonCategory(
//            id: "idioms",
//            title: "Idioms",
//            description: "Master common idioms to sound more natural",
//            icon: "quote.bubble.fill",
//            color: Color.purple,
//            progress: 0.45,
//            streak: 3
//        ),
//        LessonCategory(
//            id: "phrasal-verbs",
//            title: "Phrasal Verbs",
//            description: "Learn essential phrasal verbs for fluent speech",
//            icon: "arrow.triangle.2.circlepath",
//            color: Color.green,
//            progress: 0.60,
//            streak: 7
//        ),
//        LessonCategory(
//            id: "sample-answers",
//            title: "Sample Answers",
//            description: "Study high-scoring IELTS speaking responses",
//            icon: "mic.fill",
//            color: Color.orange,
//            progress: 0.30,
//            streak: 2
//        ),
//        LessonCategory(
//            id: "pronunciation",
//            title: "Pronunciation Tips",
//            description: "Perfect your pronunciation and intonation",
//            icon: "waveform",
//            color: Color.red,
//            progress: 0.85,
//            streak: 12
//        )
//    ]
//    
//    var body: some View {
//        ZStack {
//            // Background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Top Navigation Bar
//                HStack {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Lesson")
//                            .font(.largeTitle)
//                            .fontWeight(.bold)
//                            .foregroundColor(.primary)
//                        
//                        Text("Choose your focus area")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    Spacer()
//                    
//                    // Profile/Settings button
//                    Button(action: {}) {
//                        Image(systemName: "person.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(.accentColor)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 16)
//                
//                // Progress Overview
//                VStack(alignment: .leading, spacing: 12) {
//                    HStack {
//                        Text("Your Progress")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                        
//                        Spacer()
//                        
//                        Text("73% Complete")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    // Overall progress bar
//                    ProgressView(value: 0.73)
//                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
//                        .scaleEffect(x: 1, y: 2, anchor: .center)
//                    
//                    HStack {
//                        Label("15 day streak", systemImage: "flame.fill")
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                        
//                        Spacer()
//                        
//                        Label("245 XP this week", systemImage: "star.fill")
//                            .font(.caption)
//                            .foregroundColor(.yellow)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.vertical, 16)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color(.systemBackground))
//                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//                )
//                .padding(.horizontal, 20)
//                .padding(.bottom, 20)
//                
//                // Categories ScrollView
//                ScrollView {
//                    LazyVGrid(columns: [
//                        GridItem(.flexible(), spacing: 12),
//                        GridItem(.flexible(), spacing: 12)
//                    ], spacing: 16) {
//                        ForEach(categories) { category in
//                            CategoryCard(
//                                category: category,
//                                isSelected: selectedCategory == category.id
//                            ) {
//                                selectedCategory = category.id
//                                // Handle category selection
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 100) // Space for floating button
//                }
//            }
//            
//            // Floating Action Button
//            VStack {
//                Spacer()
//                
//                HStack {
//                    Spacer()
//                    
//                    Button(action: {
//                        showDailyLesson = true
//                    }) {
//                        HStack(spacing: 8) {
//                            Image(systemName: "dice.fill")
//                                .font(.title3)
//                            
//                            Text("Daily Lesson")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 16)
//                        .background(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        )
//                        .clipShape(Capsule())
//                        .shadow(color: .accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
//                    }
//                    .scaleEffect(showDailyLesson ? 0.95 : 1.0)
//                    .animation(.easeInOut(duration: 0.1), value: showDailyLesson)
//                    
//                    Spacer()
//                }
//                .padding(.bottom, 34)
//            }
//        }
//        .navigationBarHidden(true)
//    }
//}
//
//struct CategoryCard: View {
//    let category: LessonCategory
//    let isSelected: Bool
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            VStack(alignment: .leading, spacing: 12) {
//                // Icon and streak
//                HStack {
//                    Image(systemName: category.icon)
//                        .font(.title2)
//                        .foregroundColor(category.color)
//                    
//                    Spacer()
//                    
//                    if category.streak > 0 {
//                        HStack(spacing: 4) {
//                            Image(systemName: "flame.fill")
//                                .font(.caption)
//                                .foregroundColor(.orange)
//                            
//                            Text("\(category.streak)")
//                                .font(.caption)
//                                .fontWeight(.semibold)
//                                .foregroundColor(.orange)
//                        }
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.orange.opacity(0.15))
//                        .clipShape(Capsule())
//                    }
//                }
//                
//                // Title and description
//                VStack(alignment: .leading, spacing: 6) {
//                    Text(category.title)
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                    
//                    Text(category.description)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.leading)
//                        .lineLimit(3)
//                }
//                
//                Spacer()
//                
//                // Progress
//                VStack(alignment: .leading, spacing: 6) {
//                    HStack {
//                        Text("Progress")
//                            .font(.caption2)
//                            .fontWeight(.medium)
//                            .foregroundColor(.secondary)
//                        
//                        Spacer()
//                        
//                        Text("\(Int(category.progress * 100))%")
//                            .font(.caption2)
//                            .fontWeight(.semibold)
//                            .foregroundColor(category.color)
//                    }
//                    
//                    ProgressView(value: category.progress)
//                        .progressViewStyle(LinearProgressViewStyle(tint: category.color))
//                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
//                }
//            }
//            .padding(16)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(.systemBackground))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
//                    )
//                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//            )
//            .scaleEffect(isSelected ? 0.98 : 1.0)
//            .animation(.easeInOut(duration: 0.2), value: isSelected)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .frame(height: 180)
//    }
//}
//
//struct LessonCategory: Identifiable {
//    let id: String
//    let title: String
//    let description: String
//    let icon: String
//    let color: Color
//    let progress: Double
//    let streak: Int
//}
//
//// Preview
//struct LessonScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            LessonScreen()
//        }
//    }
//}
