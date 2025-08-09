import SwiftUI

struct LessonCategory: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let progress: Double
    let streak: Int
    let lessonCount: Int
    let illustration: String // For the character illustration
}

struct Subcategory: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let itemCount: Int
    let progress: Double
    let color: Color
    let isLocked: Bool
}

struct VocabularyItem: Identifiable {
    let id: String
    let word: String
    let definition: String
    let example: String
    let difficulty: String
    let audioURL: String?
}

struct IdiomItem: Identifiable {
    let id: String
    let idiom: String
    let meaning: String
    let example: String
    let difficulty: String
}

struct PhrasalVerbItem: Identifiable {
    let id: String
    let verb: String
    let meaning: String
    let example: String
    let difficulty: String
}

struct SampleAnswerTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let category: String
    let difficulty: String
    let estimatedTime: String
}

struct SampleAnswer: Identifiable {
    let id: String
    let question: String
    let answer: String
    let keyVocabulary: [String]
    let tips: [String]
    let bandScore: String
}

struct PronunciationTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let itemCount: Int
}

struct PronunciationItem: Identifiable {
    let id: String
    let word: String
    let ipa: String
    let difficulty: String
    let commonMistakes: [String]
    let audioURL: String?
    let example: String
}

// MARK: - Main Lesson Screen (Redesigned)
//struct LessonScreen: View {
//    @State private var selectedCategory: String? = nil
//    @State private var expandedCategory: String? = nil
//    @State private var showDailyLesson = false
//    @State private var navigationPath = NavigationPath()
//    
//    let categories = [
//        LessonCategory(
//            id: "vocabulary",
//            title: "Vocabulary",
//            description: "Build your word bank with essential IELTS vocabulary",
//            icon: "book.fill",
//            color: Color(red: 0.3, green: 0.7, blue: 1.0), // Bright blue
//            progress: 0.75,
//            streak: 5,
//            lessonCount: 32,
//            illustration: "👨‍🏫"
//        ),
//        LessonCategory(
//            id: "idioms",
//            title: "Idioms",
//            description: "Master common idioms to sound more natural",
//            icon: "quote.bubble.fill",
//            color: Color(red: 0.3, green: 0.8, blue: 0.6), // Teal green
//            progress: 0.45,
//            streak: 3,
//            lessonCount: 44,
//            illustration: "🏄‍♂️"
//        ),
//        LessonCategory(
//            id: "phrasal-verbs",
//            title: "Phrasal Verbs",
//            description: "Learn essential phrasal verbs for fluent speech",
//            icon: "arrow.triangle.2.circlepath",
//            color: Color(red: 1.0, green: 0.6, blue: 0.7), // Pink
//            progress: 0.60,
//            streak: 7,
//            lessonCount: 60,
//            illustration: "👨‍👩‍👧‍👦"
//        ),
//        LessonCategory(
//            id: "sample-answers",
//            title: "Sample Answers",
//            description: "Study high-scoring IELTS speaking responses",
//            icon: "mic.fill",
//            color: Color(red: 1.0, green: 0.5, blue: 0.3), // Orange
//            progress: 0.30,
//            streak: 2,
//            lessonCount: 60,
//            illustration: "🍽️"
//        ),
//        LessonCategory(
//            id: "pronunciation",
//            title: "Pronunciation",
//            description: "Perfect your pronunciation and intonation",
//            icon: "waveform",
//            color: Color(red: 0.6, green: 0.4, blue: 0.9), // Purple
//            progress: 0.85,
//            streak: 12,
//            lessonCount: 28,
//            illustration: "✈️"
//        )
//    ]
//    
//    var body: some View {
//        NavigationStack(path: $navigationPath) {
//            ZStack {
//                Color(.systemGroupedBackground)
//                    .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 20) {
//                        // Header
//                        headerView
//                        
//                        // Categories
//                        categoriesView
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    .padding(.bottom, 100)
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
//    private var headerView: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Lesson")
//                    .font(.custom("Fredoka-SemiBold", size: 32))
//                    .foregroundColor(.primary)
//                
//                Text("Choose your focus area")
//                    .font(.custom("Fredoka-SemiBold", size: 16))
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            Button(action: {}) {
//                Image(systemName: "person.circle.fill")
//                    .font(.title2)
//                    .foregroundColor(.accentColor)
//            }
//        }
//    }
//    
//    private var categoriesView: some View {
//        VStack(spacing: 16) {
//            ForEach(categories) { category in
//                VStack(spacing: 0) {
//                    // Main category card
//                    CategoryCard(
//                        category: category,
//                        isExpanded: expandedCategory == category.id
//                    ) {
//                        handleCategoryTap(category)
//                    }
//                    
//                    // Subcategories (expanded)
//                    if expandedCategory == category.id {
//                        subcategoriesView(for: category)
//                    }
//                }
//            }
//        }
//    }
//    
//    private func subcategoriesView(for category: LessonCategory) -> some View {
//        VStack(spacing: 12) {
//            ForEach(getSubcategories(for: category.id)) { subcategory in
//                SubcategoryCard(subcategory: subcategory) {
//                    navigationPath.append(subcategory)
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 20)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color(.systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
//        )
//        .padding(.top, -10)
//        .transition(.asymmetric(
//            insertion: .opacity.combined(with: .scale(scale: 0.95)),
//            removal: .opacity.combined(with: .scale(scale: 0.95))
//        ))
//    }
//    
//    private func handleCategoryTap(_ category: LessonCategory) {
//        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//            if expandedCategory == category.id {
//                expandedCategory = nil
//            } else {
//                expandedCategory = category.id
//            }
//        }
//    }
//    
//    private func getSubcategories(for categoryId: String) -> [Subcategory] {
//        switch categoryId {
//        case "vocabulary":
//            return MockData.vocabularySubcategories
//        case "idioms":
//            return MockData.idiomSubcategories
//        case "phrasal-verbs":
//            return MockData.phrasalVerbSubcategories
//        case "sample-answers":
//            return MockData.sampleAnswerSubcategories
//        case "pronunciation":
//            return MockData.pronunciationSubcategories
//        default:
//            return []
//        }
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

// MARK: - Category Card (Redesigned)
struct CategoryCard: View {
    let category: LessonCategory
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // Character illustration
                    VStack {
                        Text(category.illustration)
                            .font(.system(size: 50))
                        
                        // Progress circle
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .trim(from: 0.0, to: CGFloat(category.progress))
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(Int(category.progress * 100))%")
                                .font(.custom("Fredoka-SemiBold", size: 10))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 100)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.title)
                            .font(.custom("Fredoka-SemiBold", size: 24))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        
                        Text(category.description)
                            .font(.custom("Fredoka-Medium", size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(category.lessonCount) LESSONS")
                                .font(.custom("Fredoka-SemiBold", size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(category.color)
                        .shadow(color: category.color.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                
                // Continue/Unlock button
                Button(action: onTap) {
                    HStack {
                        Text(category.progress > 0 ? "Continue this lesson" : "Unlock this lesson")
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(category.color)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(category.color)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .offset(y: -8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isExpanded ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
    }
}

// MARK: - Subcategory Card (Redesigned)
struct SubcategoryCard: View {
    let subcategory: Subcategory
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Progress indicator
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(subcategory.color.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(subcategory.progress))
                            .stroke(subcategory.color, lineWidth: 4)
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(subcategory.progress * 100))%")
                            .font(.custom("Fredoka-SemiBold", size: 12))
                            .foregroundColor(subcategory.color)
                    }
                    
                    if subcategory.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(subcategory.title)
                        .font(.custom("Fredoka-SemiBold", size: 18))
                        .foregroundColor(.secondary.opacity(1.4))
                        .multilineTextAlignment(.leading)
                    
                    Text(subcategory .description)
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text("\(subcategory.itemCount) items")
                        .font(.custom("Fredoka-Medium", size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(subcategory.color)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(subcategory.color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(subcategory.color.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(subcategory.isLocked ? 0.6 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(subcategory.isLocked)
    }
}

// MARK: - Card Learning View (Updated to work with new structure)
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
//        .background(Color(.systemGroupedBackground))
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

// MARK: - Learning Card
struct LearningCard: View {
    let item: Any
    let isFlipped: Bool
    let subcategory: Subcategory
    
    var body: some View {
        VStack(spacing: 20) {
            if let vocabItem = item as? VocabularyItem {
                VocabularyCardContent(item: vocabItem, isFlipped: isFlipped, color: subcategory.color)
            } else if let idiomItem = item as? IdiomItem {
                IdiomCardContent(item: idiomItem, isFlipped: isFlipped, color: subcategory.color)
            } else if let realIdiomItem = item as? RealIdiomItemViewModel {
                RealIdiomCardContent(item: realIdiomItem, isFlipped: isFlipped, color: subcategory.color)
            } else if let phrasalItem = item as? PhrasalVerbItem {
                PhrasalVerbCardContent(item: phrasalItem, isFlipped: isFlipped, color: subcategory.color)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .frame(height: 300)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

// MARK: - Card Content Views (keeping the same implementation)
struct VocabularyCardContent: View {
    let item: VocabularyItem
    let isFlipped: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            if !isFlipped {
                // Front side - Word
                VStack(spacing: 12) {
                    Text(item.word)
                        .font(.custom("Fredoka-SemiBold", size: 32))
                        .foregroundColor(color)
                    
                    Text(item.difficulty)
                        .font(.custom("Fredoka-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.8))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text("Tap to see definition")
                    .font(.custom("Fredoka-SemiBold", size: 14))
                    .foregroundColor(.secondary)
            } else {
                // Back side - Definition and example
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Definition")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.definition)
                            .font(.custom("Fredoka-Medium", size: 16))
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.example)
                            .font(.custom("Fredoka-Medium", size: 16))
                            .foregroundColor(.primary.opacity(0.7))
                            .italic()
                    }
                    
                    Spacer()
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
}

struct IdiomCardContent: View {
    let item: IdiomItem
    let isFlipped: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            if !isFlipped {
                VStack(spacing: 12) {
                    Text(item.idiom)
                        .font(.custom("Fredoka-SemiBold", size: 24))
                        .foregroundColor(color)
                        .multilineTextAlignment(.center)
                    
                    Text(item.difficulty)
                        .font(.custom("Fredoka-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.8))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text("Tap to see meaning")
                    .font(.custom("Fredoka-SemiBold", size: 14))
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meaning")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.meaning)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.example)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Spacer()
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
}

struct PhrasalVerbCardContent: View {
    let item: PhrasalVerbItem
    let isFlipped: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            if !isFlipped {
                VStack(spacing: 12) {
                    Text(item.verb)
                        .font(.custom("Fredoka-SemiBold", size: 24))
                        .foregroundColor(color)
                        .multilineTextAlignment(.center)
                    
                    Text(item.difficulty)
                        .font(.custom("Fredoka-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.8))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text("Tap to see meaning")
                    .font(.custom("Fredoka-SemiBold", size: 14))
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meaning")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.meaning)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.example)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Spacer()
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
}

struct RealIdiomCardContent: View {
    let item: RealIdiomItemViewModel
    let isFlipped: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 16) {
            if !isFlipped {
                VStack(spacing: 12) {
                    Text(item.idiom)
                        .font(.custom("Fredoka-SemiBold", size: 24))
                        .foregroundColor(color)
                        .multilineTextAlignment(.center)
                    
                    Text(item.difficulty)
                        .font(.custom("Fredoka-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color.opacity(0.8))
                        .clipShape(Capsule())
                    
                    Text(item.category)
                        .font(.custom("Fredoka-Medium", size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                Text("Tap to see meaning")
                    .font(.custom("Fredoka-SemiBold", size: 14))
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meaning")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        Text(item.meaning)
                            .font(.custom("Fredoka-Medium", size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Examples")
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .foregroundColor(color)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(item.examples.enumerated()), id: \.offset) { index, example in
                                    Text("• \(example)")
                                        .font(.custom("Fredoka-Medium", size: 14))
                                        .foregroundColor(.primary.opacity(0.8))
                                        .italic()
                                }
                            }
                        }
                        .frame(maxHeight: 120)
                    }
                    
                    Spacer()
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
}

// MARK: - Keeping the original views for other screens
struct SubcategoryListView: View {
    let categoryId: String
    
    var subcategories: [Subcategory] {
        switch categoryId {
        case "vocabulary":
            return MockData.vocabularySubcategories
        case "idioms":
            return MockData.idiomSubcategories
        case "phrasal-verbs":
            return MockData.phrasalVerbSubcategories
        default:
            return []
        }
    }
    
    var categoryTitle: String {
        switch categoryId {
        case "vocabulary": return "Vocabulary"
        case "idioms": return "Idioms"
        case "phrasal-verbs": return "Phrasal Verbs"
        case "phrasal-verbs": return "Phrasal Verbs"
                default: return "Lessons"
                }
            }
            
            var body: some View {
                NavigationView {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(subcategories) { subcategory in
                                NavigationLink(destination: CardLearningView(subcategory: subcategory)) {
                                    SubcategoryCard(subcategory: subcategory) {}
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .navigationTitle(categoryTitle)
                    .navigationBarTitleDisplayMode(.large)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }

        // MARK: - Sample Answer Views
        struct SampleAnswerListView: View {
            @State private var selectedTopic: SampleAnswerTopic?
            
            let topics = MockData.sampleAnswerTopics
            
            var body: some View {
                NavigationView {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(topics) { topic in
                                NavigationLink(destination: SampleAnswerDetailView(topic: topic)) {
                                    SampleAnswerTopicCard(topic: topic)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Sample Answers")
                    .navigationBarTitleDisplayMode(.large)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }

        struct SampleAnswerTopicCard: View {
            let topic: SampleAnswerTopic
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(topic.title)
                                .font(.custom("Fredoka-SemiBold", size: 18))
                                .foregroundColor(.primary)
                            
                            Text(topic.description)
                                .font(.custom("Fredoka-SemiBold", size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    
                    HStack {
                        Label(topic.category, systemImage: "folder")
                            .font(.custom("Fredoka-SemiBold", size: 12))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label(topic.difficulty, systemImage: "star.fill")
                            .font(.custom("Fredoka-SemiBold", size: 12))
                            .foregroundColor(.orange)
                        
                        Label(topic.estimatedTime, systemImage: "clock")
                            .font(.custom("Fredoka-SemiBold", size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }

        struct SampleAnswerDetailView: View {
            let topic: SampleAnswerTopic
            
            var sampleAnswers: [SampleAnswer] {
                MockData.getSampleAnswers(for: topic.id)
            }
            
            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Topic header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(topic.title)
                                .font(.custom("Fredoka-SemiBold", size: 24))
                                .foregroundColor(.primary)
                            
                            Text(topic.description)
                                .font(.custom("Fredoka-SemiBold", size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Sample answers
                        ForEach(sampleAnswers) { answer in
                            SampleAnswerCard(answer: answer)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Sample Answer")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground))
            }
        }

        struct SampleAnswerCard: View {
            let answer: SampleAnswer
            
            var body: some View {
                VStack(alignment: .leading, spacing: 16) {
                    // Question
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Question")
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundColor(.accentColor)
                        
                        Text(answer.question)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    // Answer
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sample Answer")
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundColor(.accentColor)
                        
                        Text(answer.answer)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                    }
                    
                    // Key vocabulary
                    if !answer.keyVocabulary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Vocabulary")
                                .font(.custom("Fredoka-SemiBold", size: 18))
                                .foregroundColor(.accentColor)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(answer.keyVocabulary, id: \.self) { word in
                                    Text(word)
                                        .font(.custom("Fredoka-SemiBold", size: 14))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.accentColor.opacity(0.8))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    // Band score
                    HStack {
                        Text("Band Score:")
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.secondary)
                        
                        Text(answer.bandScore)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
            }
        }

        // MARK: - Pronunciation Views
        struct PronunciationListView: View {
            let topics = MockData.pronunciationTopics
            
            var body: some View {
                NavigationView {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(topics) { topic in
                                NavigationLink(destination: PronunciationDetailView(topic: topic)) {
                                    PronunciationTopicCard(topic: topic)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Pronunciation")
                    .navigationBarTitleDisplayMode(.large)
                    .background(Color(.systemGroupedBackground))
                }
            }
        }

        struct PronunciationTopicCard: View {
            let topic: PronunciationTopic
            
            var body: some View {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: "waveform")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.purple)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text(topic.title)
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundColor(.primary)
                        
                        Text(topic.description)
                            .font(.custom("Fredoka-SemiBold", size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        Text("\(topic.itemCount) sounds")
                            .font(.custom("Fredoka-SemiBold", size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.purple)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }

        struct PronunciationDetailView: View {
            let topic: PronunciationTopic
            
            var pronunciationItems: [PronunciationItem] {
                MockData.getPronunciationItems(for: topic.id)
            }
            
            var body: some View {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(pronunciationItems) { item in
                            PronunciationItemCard(item: item)
                        }
                    }
                    .padding()
                }
                .navigationTitle(topic.title)
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground))
            }
        }

        struct PronunciationItemCard: View {
            let item: PronunciationItem
            
            var body: some View {
                VStack(alignment: .leading, spacing: 16) {
                    // Word and IPA
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.word)
                                .font(.custom("Fredoka-SemiBold", size: 24))
                                .foregroundColor(.primary)
                            
                            Text(item.ipa)
                                .font(.custom("Fredoka-SemiBold", size: 18))
                                .foregroundColor(.purple)
                        }
                        
                        Spacer()
                        
                        // Play button
                        Button(action: {}) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Example
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Example")
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.purple)
                        
                        Text(item.example)
                            .font(.custom("Fredoka-SemiBold", size: 16))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    // Common mistakes
                    if !item.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Common Mistakes")
                                .font(.custom("Fredoka-SemiBold", size: 16))
                                .foregroundColor(.red)
                            
                            ForEach(item.commonMistakes, id: \.self) { mistake in
                                Text("• \(mistake)")
                                    .font(.custom("Fredoka-SemiBold", size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }

        // MARK: - Flow Layout Helper
        struct FlowLayout: Layout {
            let spacing: CGFloat
            
            init(spacing: CGFloat = 8) {
                self.spacing = spacing
            }
            
            func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
                let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
                return layout(sizes: sizes, proposal: proposal).size
            }
            
            func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
                let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
                let offsets = layout(sizes: sizes, proposal: proposal).offsets
                
                for (index, subview) in subviews.enumerated() {
                    let position = CGPoint(
                        x: bounds.minX + offsets[index].x,
                        y: bounds.minY + offsets[index].y
                    )
                    subview.place(at: position, anchor: .topLeading, proposal: .unspecified)
                }
            }
            
            private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> (offsets: [CGPoint], size: CGSize) {
                var offsets: [CGPoint] = []
                var currentRow: [CGSize] = []
                var currentRowWidth: CGFloat = 0
                var totalHeight: CGFloat = 0
                var maxWidth: CGFloat = 0
                
                let availableWidth = proposal.width ?? .infinity
                
                for size in sizes {
                    if currentRowWidth + size.width > availableWidth && !currentRow.isEmpty {
                        // Start new row
                        let rowHeight = currentRow.map(\.height).max() ?? 0
                        totalHeight += rowHeight + spacing
                        maxWidth = max(maxWidth, currentRowWidth - spacing)
                        currentRow.removeAll()
                        currentRowWidth = 0
                    }
                    
                    offsets.append(CGPoint(x: currentRowWidth, y: totalHeight))
                    currentRow.append(size)
                    currentRowWidth += size.width + spacing
                }
                
                // Handle last row
                if !currentRow.isEmpty {
                    let rowHeight = currentRow.map(\.height).max() ?? 0
                    totalHeight += rowHeight
                    maxWidth = max(maxWidth, currentRowWidth - spacing)
                }
                
                return (offsets: offsets, size: CGSize(width: maxWidth, height: totalHeight))
            }
        }

        // MARK: - Mock Data
        struct MockData {
            static let vocabularySubcategories = [
                Subcategory(id: "academic", title: "Academic Words", description: "Essential vocabulary for academic contexts", itemCount: 150, progress: 0.8, color: .blue, isLocked: false),
                Subcategory(id: "business", title: "Business English", description: "Professional vocabulary for workplace", itemCount: 120, progress: 0.6, color: .green, isLocked: false),
                Subcategory(id: "travel", title: "Travel Vocabulary", description: "Words for travel and tourism", itemCount: 90, progress: 0.4, color: .orange, isLocked: true),
                Subcategory(id: "technology", title: "Technology Terms", description: "Modern tech vocabulary", itemCount: 80, progress: 0.0, color: .purple, isLocked: true)
            ]
            
            static let idiomSubcategories = [
                Subcategory(id: "common", title: "Common Idioms", description: "Everyday idiomatic expressions", itemCount: 100, progress: 0.7, color: .red, isLocked: false),
                Subcategory(id: "business-idioms", title: "Business Idioms", description: "Professional idiomatic expressions", itemCount: 80, progress: 0.3, color: .blue, isLocked: false),
                Subcategory(id: "food", title: "Food Idioms", description: "Idioms related to food and eating", itemCount: 60, progress: 0.0, color: .yellow, isLocked: true)
            ]
            
            static let phrasalVerbSubcategories = [
                Subcategory(id: "basic", title: "Basic Phrasal Verbs", description: "Essential phrasal verbs for daily use", itemCount: 120, progress: 0.9, color: .green, isLocked: false),
                Subcategory(id: "advanced", title: "Advanced Phrasal Verbs", description: "Complex phrasal verbs for fluency", itemCount: 100, progress: 0.5, color: .purple, isLocked: false),
                Subcategory(id: "business-phrasal", title: "Business Phrasal Verbs", description: "Professional phrasal verbs", itemCount: 80, progress: 0.0, color: .blue, isLocked: true)
            ]
            
            static let sampleAnswerSubcategories = [
                Subcategory(id: "part1", title: "Part 1 Questions", description: "Introduction and interview questions", itemCount: 50, progress: 0.6, color: .orange, isLocked: false),
                Subcategory(id: "part2", title: "Part 2 Topics", description: "Individual long turn topics", itemCount: 40, progress: 0.4, color: .red, isLocked: false),
                Subcategory(id: "part3", title: "Part 3 Discussions", description: "Two-way discussion questions", itemCount: 30, progress: 0.0, color: .purple, isLocked: true)
            ]
            
            static let pronunciationSubcategories = [
                Subcategory(id: "vowels", title: "Vowel Sounds", description: "Master English vowel pronunciation", itemCount: 44, progress: 0.8, color: .pink, isLocked: false),
                Subcategory(id: "consonants", title: "Consonant Sounds", description: "Perfect consonant pronunciation", itemCount: 24, progress: 0.6, color: .blue, isLocked: false),
                Subcategory(id: "stress", title: "Word Stress", description: "Learn correct word stress patterns", itemCount: 60, progress: 0.3, color: .green, isLocked: true)
            ]
            
            static let sampleAnswerTopics = [
                SampleAnswerTopic(id: "hometown", title: "Hometown", description: "Questions about your hometown and local area", category: "Part 1", difficulty: "Easy", estimatedTime: "2 min"),
                SampleAnswerTopic(id: "hobbies", title: "Hobbies", description: "Discussing your interests and free time activities", category: "Part 1", difficulty: "Easy", estimatedTime: "2 min"),
                SampleAnswerTopic(id: "memorable-event", title: "Memorable Event", description: "Describe a memorable event from your life", category: "Part 2", difficulty: "Medium", estimatedTime: "3 min")
            ]
            
            static let pronunciationTopics = [
                PronunciationTopic(id: "vowels", title: "Vowel Sounds", description: "Master the 20 vowel sounds in English", itemCount: 20),
                PronunciationTopic(id: "consonants", title: "Consonant Sounds", description: "Perfect the 24 consonant sounds", itemCount: 24),
                PronunciationTopic(id: "minimal-pairs", title: "Minimal Pairs", description: "Distinguish between similar sounds", itemCount: 50)
            ]
            
            static func getItems(for subcategoryId: String) -> [Any] {
                switch subcategoryId {
                case "academic":
                    return [
                        VocabularyItem(id: "1", word: "Analyze", definition: "To examine something in detail", example: "We need to analyze the data carefully.", difficulty: "Medium", audioURL: nil),
                        VocabularyItem(id: "2", word: "Hypothesis", definition: "A proposed explanation for a phenomenon", example: "The scientist tested her hypothesis.", difficulty: "Advanced", audioURL: nil)
                    ]
                case "common":
                    return [
                        IdiomItem(id: "1", idiom: "Break the ice", meaning: "To start a conversation or make people feel comfortable", example: "He told a joke to break the ice.", difficulty: "Easy"),
                        IdiomItem(id: "2", idiom: "Hit the books", meaning: "To study hard", example: "I need to hit the books for my exam.", difficulty: "Easy")
                    ]
                case "basic":
                    return [
                        PhrasalVerbItem(id: "1", verb: "Look up", meaning: "To search for information", example: "I'll look up the word in the dictionary.", difficulty: "Easy"),
                        PhrasalVerbItem(id: "2", verb: "Turn down", meaning: "To reject or refuse", example: "She turned down the job offer.", difficulty: "Easy")
                    ]
                default:
                    return []
                }
            }
            
            static func getSampleAnswers(for topicId: String) -> [SampleAnswer] {
                switch topicId {
                case "hometown":
                    return [
                        SampleAnswer(
                            id: "1",
                            question: "Where are you from?",
                            answer: "I'm from Dhaka, which is the capital city of Bangladesh. It's a bustling metropolis with over 9 million people. The city is known for its rich history, vibrant culture, and delicious street food. Despite being crowded and sometimes chaotic, I love the energy and diversity of my hometown.",
                            keyVocabulary: ["metropolis", "bustling", "vibrant", "chaotic", "diversity"],
                            tips: ["Use specific details about your hometown", "Include both positive and negative aspects", "Use varied vocabulary"],
                            bandScore: "7.5"
                        )
                    ]
                default:
                    return []
                }
            }
            
            static func getPronunciationItems(for topicId: String) -> [PronunciationItem] {
                switch topicId {
                case "vowels":
                    return [
                        PronunciationItem(
                            id: "1",
                            word: "sheep",
                            ipa: "/ʃiːp/",
                            difficulty: "Easy",
                            commonMistakes: ["Pronouncing as 'ship'", "Making the vowel too short"],
                            audioURL: nil,
                            example: "The sheep is in the field."
                        ),
                        PronunciationItem(
                            id: "2",
                            word: "ship",
                            ipa: "/ʃɪp/",
                            difficulty: "Easy",
                            commonMistakes: ["Pronouncing as 'sheep'", "Making the vowel too long"],
                            audioURL: nil,
                            example: "The ship sailed across the ocean."
                        )
                    ]
                default:
                    return []
                }
            }
        }
