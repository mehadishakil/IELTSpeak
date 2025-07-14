//import SwiftUI
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
//struct Subcategory: Identifiable, Hashable {
//    let id: String
//    let title: String
//    let description: String
//    let itemCount: Int
//    let progress: Double
//    let color: Color
//}
//
//struct VocabularyItem: Identifiable {
//    let id: String
//    let word: String
//    let definition: String
//    let example: String
//    let difficulty: String
//    let audioURL: String?
//}
//
//struct IdiomItem: Identifiable {
//    let id: String
//    let idiom: String
//    let meaning: String
//    let example: String
//    let difficulty: String
//}
//
//struct PhrasalVerbItem: Identifiable {
//    let id: String
//    let verb: String
//    let meaning: String
//    let example: String
//    let difficulty: String
//}
//
//struct SampleAnswerTopic: Identifiable, Hashable {
//    let id: String
//    let title: String
//    let description: String
//    let category: String
//    let difficulty: String
//    let estimatedTime: String
//}
//
//struct SampleAnswer: Identifiable {
//    let id: String
//    let question: String
//    let answer: String
//    let keyVocabulary: [String]
//    let tips: [String]
//    let bandScore: String
//}
//
//struct PronunciationTopic: Identifiable, Hashable {
//    let id: String
//    let title: String
//    let description: String
//    let itemCount: Int
//}
//
//struct PronunciationItem: Identifiable {
//    let id: String
//    let word: String
//    let ipa: String
//    let difficulty: String
//    let commonMistakes: [String]
//    let audioURL: String?
//    let example: String
//}
//
//// MARK: - Main Lesson Screen (Updated)
//struct LessonScreen: View {
//    @State private var selectedCategory: String? = nil
//    @State private var showDailyLesson = false
//    @State private var navigationPath = NavigationPath()
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
//        NavigationStack(path: $navigationPath) {
//            ZStack {
//                LinearGradient(
//                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                VStack(spacing: 0) {
//                    // Top Navigation Bar
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Lesson")
//                                .font(.largeTitle)
//                                .fontWeight(.bold)
//                                .foregroundColor(.primary)
//                            
//                            Text("Choose your focus area")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        Spacer()
//                        
//                        Button(action: {}) {
//                            Image(systemName: "person.circle.fill")
//                                .font(.title2)
//                                .foregroundColor(.accentColor)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 16)
//                    
//                    // Progress Overview
//                    VStack(alignment: .leading, spacing: 12) {
//                        HStack {
//                            Text("Your Progress")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                            
//                            Spacer()
//                            
//                            Text("73% Complete")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        ProgressView(value: 0.73)
//                            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
//                            .scaleEffect(x: 1, y: 2, anchor: .center)
//                        
//                        HStack {
//                            Label("15 day streak", systemImage: "flame.fill")
//                                .font(.caption)
//                                .foregroundColor(.orange)
//                            
//                            Spacer()
//                            
//                            Label("245 XP this week", systemImage: "star.fill")
//                                .font(.caption)
//                                .foregroundColor(.yellow)
//                        }
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.vertical, 16)
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color(.systemBackground))
//                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//                    )
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//                    
//                    // Categories ScrollView
//                    ScrollView {
//                        LazyVGrid(columns: [
//                            GridItem(.flexible(), spacing: 12),
//                            GridItem(.flexible(), spacing: 12)
//                        ], spacing: 16) {
//                            ForEach(categories) { category in
//                                CategoryCard(
//                                    category: category,
//                                    isSelected: selectedCategory == category.id
//                                ) {
//                                    selectedCategory = category.id
//                                    handleCategorySelection(category)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 100)
//                    }
//                }
//                
//                // Floating Action Button
//                VStack {
//                    Spacer()
//                    
//                    HStack {
//                        Spacer()
//                        
//                        Button(action: {
//                            showDailyLesson = true
//                        }) {
//                            HStack(spacing: 8) {
//                                Image(systemName: "dice.fill")
//                                    .font(.title3)
//                                
//                                Text("Daily Lesson")
//                                    .font(.headline)
//                                    .fontWeight(.semibold)
//                            }
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 20)
//                            .padding(.vertical, 16)
//                            .background(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                            .clipShape(Capsule())
//                            .shadow(color: .accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
//                        }
//                        .scaleEffect(showDailyLesson ? 0.95 : 1.0)
//                        .animation(.easeInOut(duration: 0.1), value: showDailyLesson)
//                        
//                        Spacer()
//                    }
//                    .padding(.bottom, 34)
//                }
//            }
//            .navigationBarHidden(true)
//            .navigationDestination(for: String.self) { categoryId in
//                destinationView(for: categoryId)
//            }
//            .navigationDestination(for: Subcategory.self) { subcategory in
//                CardLearningView(subcategory: subcategory)
//            }
//            .navigationDestination(for: SampleAnswerTopic.self) { topic in
//                SampleAnswerDetailView(topic: topic)
//            }
//            .navigationDestination(for: PronunciationTopic.self) { topic in
//                PronunciationDetailView(topic: topic)
//            }
//        }
//    }
//    
//    private func handleCategorySelection(_ category: LessonCategory) {
//        navigationPath.append(category.id)
//    }
//    
//    @ViewBuilder
//    private func destinationView(for categoryId: String) -> some View {
//        switch categoryId {
//        case "vocabulary", "idioms", "phrasal-verbs":
//            SubcategoryListView(categoryId: categoryId)
//        case "sample-answers":
//            SampleAnswerListView()
//        case "pronunciation":
//            PronunciationListView()
//        default:
//            EmptyView()
//        }
//    }
//}
//
//// MARK: - Category Card (from original code)
//struct CategoryCard: View {
//    let category: LessonCategory
//    let isSelected: Bool
//    let onTap: () -> Void
//    
//    var body: some View {
//        Button(action: onTap) {
//            VStack(alignment: .leading, spacing: 12) {
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
//// MARK: - Subcategory List View
//struct SubcategoryListView: View {
//    let categoryId: String
//    
//    var subcategories: [Subcategory] {
//        switch categoryId {
//        case "vocabulary":
//            return MockData.vocabularySubcategories
//        case "idioms":
//            return MockData.idiomSubcategories
//        case "phrasal-verbs":
//            return MockData.phrasalVerbSubcategories
//        default:
//            return []
//        }
//    }
//    
//    var categoryTitle: String {
//        switch categoryId {
//        case "vocabulary": return "Vocabulary"
//        case "idioms": return "Idioms"
//        case "phrasal-verbs": return "Phrasal Verbs"
//        default: return "Topics"
//        }
//    }
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 16) {
//                ForEach(subcategories) { subcategory in
//                    NavigationLink(value: subcategory) {
//                        SubcategoryCard(subcategory: subcategory)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//        }
//        .navigationTitle(categoryTitle)
//        .navigationBarTitleDisplayMode(.large)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//// MARK: - Subcategory Card
//struct SubcategoryCard: View {
//    let subcategory: Subcategory
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            // Color indicator
//            RoundedRectangle(cornerRadius: 6)
//                .fill(subcategory.color)
//                .frame(width: 6, height: 60)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text(subcategory.title)
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                    
//                    Spacer()
//                    
//                    Text("\(subcategory.itemCount) items")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color(.systemGray5))
//                        .clipShape(Capsule())
//                }
//                
//                Text(subcategory.description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(2)
//                
//                // Progress bar
//                HStack {
//                    ProgressView(value: subcategory.progress)
//                        .progressViewStyle(LinearProgressViewStyle(tint: subcategory.color))
//                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
//                    
//                    Text("\(Int(subcategory.progress * 100))%")
//                        .font(.caption)
//                        .fontWeight(.semibold)
//                        .foregroundColor(subcategory.color)
//                }
//            }
//            
//            Image(systemName: "chevron.right")
//                .font(.body)
//                .foregroundColor(.secondary)
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//        )
//    }
//}
//
//// MARK: - Card Learning View (Swipeable Cards)
//struct CardLearningView: View {
//    let subcategory: Subcategory
//    @State private var currentIndex = 0
//    @State private var dragOffset = CGSize.zero
//    @State private var isFlipped = false
//    
//    var items: [Any] {
//        MockData.getItems(for: subcategory.id)
//    }
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            // Progress indicator
//            progressIndicator
//            
//            // Card stack
//            cardStack
//            
//            // Control buttons
//            controlButtons
//        }
//        .padding()
//        .navigationTitle(subcategory.title)
//        .navigationBarTitleDisplayMode(.inline)
//        .onTapGesture {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                isFlipped.toggle()
//            }
//        }
//    }
//    
//    // MARK: - Progress Indicator
//    private var progressIndicator: some View {
//        HStack {
//            ForEach(0..<items.count, id: \.self) { index in
//                progressDot(for: index)
//            }
//        }
//        .padding(.horizontal)
//    }
//    
//    private func progressDot(for index: Int) -> some View {
//        Circle()
//            .fill(index <= currentIndex ? subcategory.color : Color(.systemGray4))
//            .frame(width: 8, height: 8)
//            .scaleEffect(index == currentIndex ? 1.2 : 1.0)
//            .animation(.easeInOut(duration: 0.2), value: currentIndex)
//    }
//    
//    // MARK: - Card Stack
//    private var cardStack: some View {
//        ZStack {
//            ForEach(visibleCardIndices, id: \.self) { index in
//                cardView(for: index)
//            }
//        }
//        .gesture(dragGesture)
//    }
//    
//    private var visibleCardIndices: [Int] {
//        let startIndex = currentIndex
//        let endIndex = min(currentIndex + 3, items.count)
//        return Array(startIndex..<endIndex)
//    }
//    
//    private func cardView(for index: Int) -> some View {
//        let item = items[index]
//        let isCurrentCard = index == currentIndex
//        let cardOffset = index - currentIndex
//        
//        return LearningCard(
//            item: item,
//            isFlipped: isFlipped && isCurrentCard,
//            subcategory: subcategory
//        )
//        .offset(x: isCurrentCard ? dragOffset.width : 0)
//        .scaleEffect(calculateScale(for: cardOffset))
//        .opacity(calculateOpacity(for: cardOffset))
//        .zIndex(Double(items.count - index))
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
//    }
//    
//    private func calculateScale(for offset: Int) -> CGFloat {
//        if offset == 0 { return 1.0 }
//        return 0.95 - Double(offset) * 0.05
//    }
//    
//    private func calculateOpacity(for offset: Int) -> Double {
//        if offset == 0 { return 1.0 }
//        return 0.7 - Double(offset) * 0.2
//    }
//    
//    // MARK: - Drag Gesture
//    private var dragGesture: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                dragOffset = value.translation
//            }
//            .onEnded { value in
//                handleDragEnd(value)
//            }
//    }
//    
//    private func handleDragEnd(_ value: DragGesture.Value) {
//        let threshold: CGFloat = 100
//        
//        if abs(value.translation.width) > threshold {
//            if value.translation.width > 0 {
//                // Swipe right - previous card
//                moveToPreviousCard()
//            } else {
//                // Swipe left - next card
//                moveToNextCard()
//            }
//        }
//        
//        dragOffset = .zero
//    }
//    
//    private func moveToPreviousCard() {
//        if currentIndex > 0 {
//            currentIndex -= 1
//            isFlipped = false
//        }
//    }
//    
//    private func moveToNextCard() {
//        if currentIndex < items.count - 1 {
//            currentIndex += 1
//            isFlipped = false
//        }
//    }
//    
//    // MARK: - Control Buttons
//    private var controlButtons: some View {
//        HStack(spacing: 40) {
//            previousButton
//            flipButton
//            nextButton
//        }
//        .padding()
//    }
//    
//    private var previousButton: some View {
//        Button(action: moveToPreviousCard) {
//            Image(systemName: "chevron.left")
//                .font(.title2)
//                .foregroundColor(canMoveToPrevious ? subcategory.color : .secondary)
//        }
//        .disabled(!canMoveToPrevious)
//    }
//    
//    private var flipButton: some View {
//        Button(action: toggleFlip) {
//            Image(systemName: isFlipped ? "eye.slash" : "eye")
//                .font(.title2)
//                .foregroundColor(subcategory.color)
//        }
//    }
//    
//    private var nextButton: some View {
//        Button(action: moveToNextCard) {
//            Image(systemName: "chevron.right")
//                .font(.title2)
//                .foregroundColor(canMoveToNext ? subcategory.color : .secondary)
//        }
//        .disabled(!canMoveToNext)
//    }
//    
//    // MARK: - Helper Properties
//    private var canMoveToPrevious: Bool {
//        currentIndex > 0
//    }
//    
//    private var canMoveToNext: Bool {
//        currentIndex < items.count - 1
//    }
//    
//    private func toggleFlip() {
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//            isFlipped.toggle()
//        }
//    }
//}
//
//// MARK: - Learning Card
//struct LearningCard: View {
//    let item: Any
//    let isFlipped: Bool
//    let subcategory: Subcategory
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            if let vocabItem = item as? VocabularyItem {
//                VocabularyCardContent(item: vocabItem, isFlipped: isFlipped, color: subcategory.color)
//            } else if let idiomItem = item as? IdiomItem {
//                IdiomCardContent(item: idiomItem, isFlipped: isFlipped, color: subcategory.color)
//            } else if let phrasalItem = item as? PhrasalVerbItem {
//                PhrasalVerbCardContent(item: phrasalItem, isFlipped: isFlipped, color: subcategory.color)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(24)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
//        )
//        .frame(height: 300)
//        .rotation3DEffect(
//            .degrees(isFlipped ? 180 : 0),
//            axis: (x: 0, y: 1, z: 0)
//        )
//    }
//}
//
//// MARK: - Card Content Views
//struct VocabularyCardContent: View {
//    let item: VocabularyItem
//    let isFlipped: Bool
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            if !isFlipped {
//                // Front side - Word
//                VStack(spacing: 12) {
//                    Text(item.word)
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(color)
//                    
//                    Text(item.difficulty)
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(color.opacity(0.8))
//                        .clipShape(Capsule())
//                }
//                
//                Spacer()
//                
//                Text("Tap to see definition")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            } else {
//                // Back side - Definition and example
//                VStack(alignment: .leading, spacing: 16) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Definition")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(color)
//                        
//                        Text(item.definition)
//                            .font(.body)
//                            .foregroundColor(.primary)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Example")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(color)
//                        
//                        Text(item.example)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .italic()
//                    }
//                    
//                    Spacer()
//                }
//                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//            }
//        }
//    }
//}
//
//struct IdiomCardContent: View {
//    let item: IdiomItem
//    let isFlipped: Bool
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            if !isFlipped {
//                VStack(spacing: 12) {
//                    Text(item.idiom)
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(color)
//                        .multilineTextAlignment(.center)
//                    
//                    Text(item.difficulty)
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(color.opacity(0.8))
//                        .clipShape(Capsule())
//                }
//                
//                Spacer()
//                
//                Text("Tap to see meaning")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            } else {
//                VStack(alignment: .leading, spacing: 16) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Meaning")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(color)
//                        
//                        Text(item.meaning)
//                            .font(.body)
//                            .foregroundColor(.primary)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Example")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(color)
//                        
//                        Text(item.example)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .italic()
//                    }
//                    
//                    Spacer()
//                }
//                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//            }
//        }
//    }
//}
//
//struct PhrasalVerbCardContent: View {
//    let item: PhrasalVerbItem
//    let isFlipped: Bool
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            if !isFlipped {
//                VStack(spacing: 12) {
//                    Text(item.verb)
//                        .font(.title)
//                        .fontWeight(.bold)
//                        .foregroundColor(color)
//                        .multilineTextAlignment(.center)
//                    
//                    Text(item.difficulty)
//                        .font(.caption)
//                        .fontWeight(.medium)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 6)
//                        .background(color.opacity(0.8))
//                        .clipShape(Capsule())
//                }
//                
//                Spacer()
//                
//                Text("Tap to see meaning")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            } else {
//                VStack(alignment: .leading, spacing: 16) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Meaning")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(color)
//                        
//                        Text(item.meaning)
//                            .font(.body)
//                            .foregroundColor(.primary)
//                    }
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Example")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(color)
//                        
//                        Text(item.example)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .italic()
//                    }
//                    
//                    Spacer()
//                }
//                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//            }
//        }
//    }
//}
//
//// MARK: - Sample Answer Views
//struct SampleAnswerListView: View {
//    let topics = MockData.sampleAnswerTopics
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                ForEach(topics) { topic in
//                    NavigationLink(value: topic) {
//                        SampleAnswerTopicCard(topic: topic)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//        }
//        .navigationTitle("Sample Answers")
//        .navigationBarTitleDisplayMode(.large)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//struct SampleAnswerTopicCard: View {
//    let topic: SampleAnswerTopic
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text(topic.title)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                Text(topic.difficulty)
//                    .font(.caption)
//                    .fontWeight(.medium)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color.orange)
//                    .clipShape(Capsule())
//            }
//            
//            Text(topic.description)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .lineLimit(3)
//            
//            HStack {
//                Label(topic.category, systemImage: "tag")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                Label(topic.estimatedTime, systemImage: "clock")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//        )
//    }
//}
//
//struct SampleAnswerDetailView: View {
//    let topic: SampleAnswerTopic
//    @State private var selectedAnswer: SampleAnswer?
//    
//    var answers: [SampleAnswer] {
//        MockData.getSampleAnswers(for: topic.id)
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Topic header
//                VStack(alignment: .leading, spacing: 8) {
//                    Text(topic.title)
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                    
//                    Text(topic.description)
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                }
//                .padding(.horizontal, 20)
//                
//                // Sample answers
//                ForEach(answers) { answer in
//                    SampleAnswerCard(answer: answer)
//                        .padding(.horizontal, 20)
//                }
//            }
//            .padding(.vertical, 16)
//        }
//        .navigationTitle("Sample Answers")
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//struct SampleAnswerCard: View {
//    let answer: SampleAnswer
//    @State private var isExpanded = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Question
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text("Question")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.orange)
//                    
//                    Spacer()
//                    
//                    Text("Band \(answer.bandScore)")
//                        .font(.caption)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.green)
//                        .clipShape(Capsule())
//                }
//                
//                Text(answer.question)
//                    .font(.body)
//                    .foregroundColor(.primary)
//            }
//            
//            // Answer
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text("Sample Answer")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.orange)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.3)) {
//                            isExpanded.toggle()
//                        }
//                    }) {
//                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                    }
//                }
//                
//                Text(answer.answer)
//                    .font(.body)
//                    .foregroundColor(.primary)
//                    .lineLimit(isExpanded ? nil : 4)
//                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
//            }
//            
//            if isExpanded {
//                // Key vocabulary
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Key Vocabulary")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.orange)
//                    
//                    LazyVGrid(columns: [
//                        GridItem(.flexible()),
//                        GridItem(.flexible())
//                    ], spacing: 8) {
//                        ForEach(answer.keyVocabulary, id: \.self) { word in
//                            Text(word)
//                                .font(.caption)
//                                .foregroundColor(.orange)
//                                .padding(.horizontal, 8)
//                                .padding(.vertical, 4)
//                                .background(Color.orange.opacity(0.1))
//                                .clipShape(Capsule())
//                        }
//                    }
//                }
//                
//                // Tips
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Tips")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.orange)
//                    
//                    ForEach(answer.tips, id: \.self) { tip in
//                        HStack(alignment: .top, spacing: 8) {
//                            Image(systemName: "lightbulb.fill")
//                                .font(.caption)
//                                .foregroundColor(.yellow)
//                            
//                            Text(tip)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//        )
//    }
//}
//
//// MARK: - Pronunciation Views
//struct PronunciationListView: View {
//    let topics = MockData.pronunciationTopics
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                ForEach(topics) { topic in
//                    NavigationLink(value: topic) {
//                        PronunciationTopicCard(topic: topic)
//                    }
//                    .buttonStyle(PlainButtonStyle())
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//        }
//        .navigationTitle("Pronunciation")
//        .navigationBarTitleDisplayMode(.large)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//struct PronunciationTopicCard: View {
//    let topic: PronunciationTopic
//    
//    var body: some View {
//        HStack(spacing: 16) {
//            // Sound wave icon
//            Image(systemName: "waveform")
//                .font(.title2)
//                .foregroundColor(.red)
//                .frame(width: 40, height: 40)
//                .background(Color.red.opacity(0.1))
//                .clipShape(Circle())
//            
//            VStack(alignment: .leading, spacing: 8) {
//                Text(topic.title)
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//                
//                Text(topic.description)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .lineLimit(2)
//                
//                Text("\(topic.itemCount) sounds")
//                    .font(.caption)
//                    .foregroundColor(.red)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.body)
//                .foregroundColor(.secondary)
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//        )
//    }
//}
//
//struct PronunciationDetailView: View {
//    let topic: PronunciationTopic
//    
//    var items: [PronunciationItem] {
//        MockData.getPronunciationItems(for: topic.id)
//    }
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                ForEach(items) { item in
//                    PronunciationItemCard(item: item)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//        }
//        .navigationTitle(topic.title)
//        .navigationBarTitleDisplayMode(.inline)
//        .background(Color(.systemGroupedBackground))
//    }
//}
//
//struct PronunciationItemCard: View {
//    let item: PronunciationItem
//    @State private var isPlaying = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // Word and IPA
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(item.word)
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.primary)
//                    
//                    Text(item.ipa)
//                        .font(.title3)
//                        .foregroundColor(.red)
//                        .monospaced()
//                }
//                
//                Spacer()
//                
//                // Audio button
//                Button(action: {
//                    playAudio()
//                }) {
//                    Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.2.fill")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                        .frame(width: 50, height: 50)
//                        .background(Color.red)
//                        .clipShape(Circle())
//                        .scaleEffect(isPlaying ? 1.1 : 1.0)
//                        .animation(.easeInOut(duration: 0.2), value: isPlaying)
//                }
//            }
//            
//            // Difficulty
//            HStack {
//                Text(item.difficulty)
//                    .font(.caption)
//                    .fontWeight(.medium)
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color.red.opacity(0.8))
//                    .clipShape(Capsule())
//                
//                Spacer()
//            }
//            
//            // Example sentence
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Example")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.red)
//                
//                Text(item.example)
//                    .font(.body)
//                    .foregroundColor(.primary)
//            }
//            
//            // Common mistakes
//            if !item.commonMistakes.isEmpty {
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Common Mistakes")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                        .foregroundColor(.red)
//                    
//                    ForEach(item.commonMistakes, id: \.self) { mistake in
//                        HStack(alignment: .top, spacing: 8) {
//                            Image(systemName: "exclamationmark.triangle.fill")
//                                .font(.caption)
//                                .foregroundColor(.orange)
//                            
//                            Text(mistake)
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                }
//            }
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
//        )
//    }
//    
//    private func playAudio() {
//        isPlaying = true
//        
//        // Simulate audio playback
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            isPlaying = false
//        }
//    }
//}
//
//// MARK: - Mock Data
//struct MockData {
//    static let vocabularySubcategories = [
//        Subcategory(id: "health", title: "Health & Care", description: "Medical terminology and health-related vocabulary", itemCount: 45, progress: 0.8, color: .blue),
//        Subcategory(id: "education", title: "Education", description: "Academic and learning vocabulary", itemCount: 52, progress: 0.6, color: .blue),
//        Subcategory(id: "economics", title: "Economics", description: "Business and financial terms", itemCount: 38, progress: 0.4, color: .blue),
//        Subcategory(id: "environment", title: "Environment", description: "Nature and environmental issues", itemCount: 41, progress: 0.7, color: .blue),
//        Subcategory(id: "technology", title: "Technology", description: "Modern technology and digital terms", itemCount: 35, progress: 0.5, color: .blue)
//    ]
//    
//    static let idiomSubcategories = [
//        Subcategory(id: "common", title: "Common Idioms", description: "Everyday expressions and phrases", itemCount: 30, progress: 0.9, color: .purple),
//        Subcategory(id: "business", title: "Business Idioms", description: "Professional and workplace expressions", itemCount: 25, progress: 0.3, color: .purple),
//        Subcategory(id: "emotions", title: "Emotions & Feelings", description: "Expressing emotions through idioms", itemCount: 28, progress: 0.6, color: .purple),
//        Subcategory(id: "time", title: "Time & Money", description: "Idioms about time and financial matters", itemCount: 22, progress: 0.4, color: .purple)
//    ]
//    
//    static let phrasalVerbSubcategories = [
//        Subcategory(id: "daily", title: "Daily Activities", description: "Common phrasal verbs for everyday use", itemCount: 40, progress: 0.8, color: .green),
//        Subcategory(id: "business", title: "Business & Work", description: "Professional phrasal verbs", itemCount: 32, progress: 0.5, color: .green),
//        Subcategory(id: "relationships", title: "Relationships", description: "Phrasal verbs about people and relationships", itemCount: 28, progress: 0.7, color: .green),
//        Subcategory(id: "travel", title: "Travel & Transport", description: "Movement and travel phrasal verbs", itemCount: 24, progress: 0.3, color: .green)
//    ]
//    
//    static let sampleAnswerTopics = [
//        SampleAnswerTopic(id: "environment", title: "Environment", description: "Climate change, pollution, and conservation topics", category: "Nature", difficulty: "Band 7-8", estimatedTime: "15 min"),
//        SampleAnswerTopic(id: "technology", title: "Technology", description: "Impact of technology on society and daily life", category: "Modern Life", difficulty: "Band 6-7", estimatedTime: "12 min"),
//        SampleAnswerTopic(id: "education", title: "Education", description: "Learning methods, school systems, and academic topics", category: "Society", difficulty: "Band 7-9", estimatedTime: "18 min"),
//        SampleAnswerTopic(id: "work", title: "Work & Career", description: "Jobs, career development, and workplace topics", category: "Professional", difficulty: "Band 6-8", estimatedTime: "14 min")
//    ]
//    
//    static let pronunciationTopics = [
//        PronunciationTopic(id: "vowels", title: "Vowel Sounds", description: "Master the 12 English vowel sounds", itemCount: 12),
//        PronunciationTopic(id: "consonants", title: "Consonant Clusters", description: "Practice difficult consonant combinations", itemCount: 15),
//        PronunciationTopic(id: "stress", title: "Word Stress", description: "Learn correct stress patterns", itemCount: 20),
//        PronunciationTopic(id: "intonation", title: "Intonation Patterns", description: "Master rising and falling tones", itemCount: 8)
//    ]
//    
//    static func getItems(for subcategoryId: String) -> [Any] {
//        switch subcategoryId {
//        case "health":
//            return [
//                VocabularyItem(id: "1", word: "Ailment", definition: "A minor illness or health problem", example: "The doctor treated her minor ailment with rest and medication.", difficulty: "Intermediate", audioURL: nil),
//                VocabularyItem(id: "2", word: "Chronic", definition: "Persisting for a long time or constantly recurring", example: "He suffers from chronic back pain due to his old injury.", difficulty: "Advanced", audioURL: nil),
//                VocabularyItem(id: "3", word: "Remedy", definition: "A medicine or treatment for a disease or injury", example: "Herbal remedies are becoming increasingly popular.", difficulty: "Intermediate", audioURL: nil)
//            ]
//        case "common":
//            return [
//                IdiomItem(id: "1", idiom: "Break the ice", meaning: "To initiate conversation or make people feel comfortable", example: "He told a joke to break the ice at the meeting.", difficulty: "Beginner"),
//                IdiomItem(id: "2", idiom: "Cost an arm and a leg", meaning: "To be very expensive", example: "The new smartphone costs an arm and a leg.", difficulty: "Intermediate"),
//                IdiomItem(id: "3", idiom: "Hit the nail on the head", meaning: "To describe exactly what is causing a situation or problem", example: "You hit the nail on the head with your analysis.", difficulty: "Advanced")
//            ]
//        case "daily":
//            return [
//                PhrasalVerbItem(id: "1", verb: "Get up", meaning: "To rise from bed or stand up", example: "I get up at 7 AM every morning.", difficulty: "Beginner"),
//                PhrasalVerbItem(id: "2", verb: "Look after", meaning: "To take care of someone or something", example: "She looks after her elderly parents.", difficulty: "Beginner"),
//                PhrasalVerbItem(id: "3", verb: "Put off", meaning: "To postpone or delay something", example: "We had to put off the meeting until next week.", difficulty: "Intermediate")
//            ]
//        default:
//            return []
//        }
//    }
//    
//    static func getSampleAnswers(for topicId: String) -> [SampleAnswer] {
//        switch topicId {
//        case "environment":
//            return [
//                SampleAnswer(
//                    id: "1",
//                    question: "What are the main environmental problems in your country?",
//                    answer: "In my country, we face several significant environmental challenges. The most pressing issue is air pollution, particularly in major cities where vehicle emissions and industrial activities have led to poor air quality. Additionally, water contamination from industrial waste and improper sewage treatment affects many communities. Deforestation is another concern, as rapid urbanization has led to the destruction of natural habitats. Climate change impacts, such as irregular rainfall patterns and extreme weather events, are also becoming more apparent. These problems require urgent attention and collaborative efforts from both government and citizens to address effectively.",
//                    keyVocabulary: ["air pollution", "vehicle emissions", "industrial activities", "water contamination", "deforestation", "urbanization", "climate change"],
//                    tips: ["Use specific examples from your country", "Mention both causes and effects", "Show awareness of global issues"],
//                    bandScore: "7.5"
//                )
//            ]
//        case "technology":
//            return [
//                SampleAnswer(
//                    id: "1",
//                    question: "How has technology changed the way people communicate?",
//                    answer: "Technology has revolutionized communication in numerous ways. Social media platforms and messaging apps have made it possible to connect with people instantly, regardless of geographical distance. Video calls have replaced many face-to-face meetings, especially during the pandemic. However, this shift has also led to a decrease in formal letter writing and in-person conversations. While technology has made communication more convenient and accessible, some argue that it has also made our interactions more superficial and less meaningful.",
//                    keyVocabulary: ["revolutionized", "social media platforms", "messaging apps", "geographical distance", "video calls", "superficial", "meaningful"],
//                    tips: ["Discuss both positive and negative aspects", "Use present perfect tense for changes over time", "Give concrete examples"],
//                    bandScore: "7.0"
//                )
//            ]
//        default:
//            return []
//        }
//    }
//    
//    static func getPronunciationItems(for topicId: String) -> [PronunciationItem] {
//        switch topicId {
//        case "vowels":
//            return [
//                PronunciationItem(
//                    id: "1",
//                    word: "beat",
//                    ipa: "/biːt/",
//                    difficulty: "Beginner",
//                    commonMistakes: ["Confusing with 'bit' /bɪt/", "Making the vowel too short"],
//                    audioURL: nil,
//                    example: "The drummer kept a steady beat throughout the song."
//                ),
//                PronunciationItem(
//                    id: "2",
//                    word: "bought",
//                    ipa: "/bɔːt/",
//                    difficulty: "Intermediate",
//                    commonMistakes: ["Confusing with 'boat' /boʊt/", "Not rounding the lips enough"],
//                    audioURL: nil,
//                    example: "I bought a new car last week."
//                )
//            ]
//        case "consonants":
//            return [
//                PronunciationItem(
//                    id: "1",
//                    word: "strength",
//                    ipa: "/streŋθ/",
//                    difficulty: "Advanced",
//                    commonMistakes: ["Adding extra vowel sounds", "Not pronouncing the 'th' sound clearly"],
//                    audioURL: nil,
//                    example: "Physical strength is important for this job."
//                )
//            ]
//        default:
//            return []
//        }
//    }
//}
//
//// MARK: - Preview
//struct LessonScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        LessonScreen()
//    }
//}
