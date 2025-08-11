//
//  LessonScreen 2.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 2/8/25.
//


import SwiftUI

// MARK: - Updated LessonScreen
struct LessonScreen: View {
    @StateObject private var dataManager = LessonDataManager.shared
    @State private var selectedCategory: String? = nil
    @State private var expandedCategory: String? = nil
    @State private var showDailyLesson = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if dataManager.isLoading {
                    loadingView
                } else if let error = dataManager.error {
                    errorView(error: error)
                } else {
                    contentView
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { categoryId in
                destinationView(for: categoryId)
            }
            .navigationDestination(for: Subcategory.self) { subcategory in
                if subcategory.id.hasPrefix("vocab_") {
                    // Extract topic from subcategory id (format: "vocab_topicname")
                    let topic = String(subcategory.id.dropFirst(6)) // Remove "vocab_" prefix
                    NewVocabularyView(topic: topic)
                } else if subcategory.id == "sample-answers-part1" {
                    if let sampleAnswersData = dataManager.sampleAnswersData {
                        Part1SampleAnswersView(data: sampleAnswersData.part_1_sample_answers)
                    } else {
                        VStack {
                            Text("Loading Sample Answers...")
                                .font(.custom("Fredoka-SemiBold", size: 18))
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else if subcategory.id == "sample-answers-part2" {
                    if let sampleAnswersData = dataManager.sampleAnswersData {
                        Part2SampleAnswersView(data: sampleAnswersData.part_2_sample_answers)
                    } else {
                        VStack {
                            Text("Loading Sample Answers...")
                                .font(.custom("Fredoka-SemiBold", size: 18))
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else if subcategory.id == "sample-answers-part3" {
                    if let sampleAnswersData = dataManager.sampleAnswersData {
                        Part3SampleAnswersView(data: sampleAnswersData.part_3_sample_answers)
                    } else {
                        VStack {
                            Text("Loading Sample Answers...")
                                .font(.custom("Fredoka-SemiBold", size: 18))
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    CardLearningView(subcategory: subcategory)
                }
            }
            .navigationDestination(for: SampleAnswerTopic.self) { topic in
                EmptyView() // Removed - using new SampleAnswersView instead
            }
            .onAppear {
                if dataManager.categories.isEmpty {
                    dataManager.loadData()
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading lessons...")
                .font(.custom("Fredoka-SemiBold", size: 18))
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(error: DataError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.custom("Fredoka-SemiBold", size: 24))
                .foregroundColor(.primary)
            
            Text(error.localizedDescription)
                .font(.custom("Fredoka-SemiBold", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                dataManager.loadData()
            }
            .font(.custom("Fredoka-SemiBold", size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.accentColor)
            .clipShape(Capsule())
        }
        .padding(40)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Categories
                categoriesView
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .refreshable {
            dataManager.loadData()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lesson")
                    .font(.custom("Fredoka-SemiBold", size: 32))
                    .foregroundColor(.primary)
                
                Text("Choose your focus area")
                    .font(.custom("Fredoka-SemiBold", size: 16))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private var categoriesView: some View {
        VStack(spacing: 16) {
            ForEach(dataManager.categories) { category in
                VStack(spacing: 0) {
                    // Main category card
                    CategoryCard(
                        category: category,
                        isExpanded: expandedCategory == category.id
                    ) {
                        handleCategoryTap(category)
                    }
                    
                    // Subcategories (expanded)
                    if expandedCategory == category.id {
                        subcategoriesView(for: category)
                    }
                }
            }
        }
    }
    
    private func subcategoriesView(for category: LessonCategory) -> some View {
        let subcategories = dataManager.getSubcategories(for: category.id)
        
        return VStack(spacing: 12) {
            ForEach(subcategories) { subcategory in
                SubcategoryCard(subcategory: subcategory) {
                    navigationPath.append(subcategory)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.top, -10)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 0.95))
        ))
    }
    
    private func handleCategoryTap(_ category: LessonCategory) {
        // Expand/collapse to show subcategories for all categories
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            if expandedCategory == category.id {
                expandedCategory = nil
            } else {
                expandedCategory = category.id
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for categoryId: String) -> some View {
        switch categoryId {
        case "vocabulary":
            NewVocabularyView()
        case "idioms", "phrasal-verbs":
            SubcategoryListView(categoryId: categoryId)
        case "sample-answers":
            SampleAnswersView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Updated CardLearningView
struct CardLearningView: View {
    let subcategory: Subcategory
    @StateObject private var dataManager = LessonDataManager.shared
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var isFlipped = false
    @State private var items: [Any] = []
    
    var body: some View {
        VStack(spacing: 20) {
            if items.isEmpty {
                loadingView
            } else {
                // Progress indicator
                progressIndicator
                
                // Card stack
                cardStack
                
                // Control buttons
                controlButtons
            }
        }
        .padding()
        .navigationTitle(subcategory.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadItems()
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isFlipped.toggle()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading content...")
                .font(.custom("Fredoka-SemiBold", size: 18))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadItems() {
        // Determine item type based on subcategory ID pattern or category
        if subcategory.id.contains("vocabulary") || subcategory.id == "academic" || subcategory.id == "business" {
            items = dataManager.getVocabularyItems(for: subcategory.id)
        } else if subcategory.id.hasPrefix("real_idioms_") {
            // Handle real idioms data
            items = dataManager.getRealIdiomItems(for: subcategory.id)
        } else if subcategory.id.hasPrefix("real_phrasal_verbs_") {
            // Handle real phrasal verbs data
            items = dataManager.getRealPhrasalVerbItems(for: subcategory.id)
        } else if subcategory.id.contains("idiom") || subcategory.id == "common" {
            items = dataManager.getIdiomItems(for: subcategory.id)
        } else if subcategory.id.contains("phrasal") || subcategory.id == "basic" || subcategory.id == "advanced" {
            items = dataManager.getPhrasalVerbItems(for: subcategory.id)
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack {
            Text("\(currentIndex+1)/\(items.count)")
        }
        .padding(.horizontal)
    }
    
    private func progressDot(for index: Int) -> some View {
        Circle()
            .fill(index <= currentIndex ? subcategory.color : Color(.systemGray4))
            .frame(width: 8, height: 8)
            .scaleEffect(index == currentIndex ? 1.2 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: currentIndex)
    }
    
    // MARK: - Card Stack
    private var cardStack: some View {
        ZStack {
            ForEach(visibleCardIndices, id: \.self) { index in
                cardView(for: index)
            }
        }
        .gesture(dragGesture)
    }
    
    private var visibleCardIndices: [Int] {
        let startIndex = currentIndex
        let endIndex = min(currentIndex + 3, items.count)
        return Array(startIndex..<endIndex)
    }
    
    private func cardView(for index: Int) -> some View {
        let item = items[index]
        let isCurrentCard = index == currentIndex
        let cardOffset = index - currentIndex
        
        return LearningCard(
            item: item,
            isFlipped: isFlipped && isCurrentCard,
            subcategory: subcategory
        )
        .offset(x: isCurrentCard ? dragOffset.width : 0)
        .scaleEffect(calculateScale(for: cardOffset))
        .opacity(calculateOpacity(for: cardOffset))
        .zIndex(Double(items.count - index))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
    }
    
    private func calculateScale(for offset: Int) -> CGFloat {
        if offset == 0 { return 1.0 }
        return 0.95 - Double(offset) * 0.05
    }
    
    private func calculateOpacity(for offset: Int) -> Double {
        if offset == 0 { return 1.0 }
        return 0.7 - Double(offset) * 0.2
    }
    
    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                handleDragEnd(value)
            }
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        let threshold: CGFloat = 100
        
        if abs(value.translation.width) > threshold {
            if value.translation.width > 0 {
                // Swipe right - previous card
                moveToPreviousCard()
            } else {
                // Swipe left - next card
                moveToNextCard()
            }
        }
        
        dragOffset = .zero
    }
    
    private func moveToPreviousCard() {
        if currentIndex > 0 {
            currentIndex -= 1
            isFlipped = false
        }
    }
    
    private func moveToNextCard() {
        if currentIndex < items.count - 1 {
            // Mark current item as completed
            markCurrentItemCompleted()
            currentIndex += 1
            isFlipped = false
        }
    }
    
    private func markCurrentItemCompleted() {
        let item = items[currentIndex]
        var itemId: String = ""
        
        if let vocabItem = item as? VocabularyItem {
            itemId = vocabItem.id
        } else if let idiomItem = item as? IdiomItem {
            itemId = idiomItem.id
        } else if let realIdiomItem = item as? RealIdiomItemViewModel {
            itemId = realIdiomItem.id.uuidString
        } else if let realPhrasalVerbItem = item as? RealPhrasalVerbItemViewModel {
            itemId = realPhrasalVerbItem.id.uuidString
        } else if let phrasalItem = item as? PhrasalVerbItem {
            itemId = phrasalItem.id
        }
        
        if !itemId.isEmpty {
            // You'll need to determine the categoryId based on your data structure
            let categoryId = getCategoryId(for: subcategory.id)
            dataManager.markItemCompleted(
                itemId: itemId,
                subcategoryId: subcategory.id,
                categoryId: categoryId
            )
        }
    }
    
    private func getCategoryId(for subcategoryId: String) -> String {
        // Map subcategory to category - you might want to store this in your data
        if subcategoryId.contains("academic") || subcategoryId.contains("business") {
            return "vocabulary"
        } else if subcategoryId.hasPrefix("real_idioms_") || subcategoryId.contains("common") {
            return "idioms"
        } else if subcategoryId.hasPrefix("real_phrasal_verbs_") || subcategoryId.contains("basic") || subcategoryId.contains("advanced") {
            return "phrasal-verbs"
        }
        return "vocabulary" // default
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 40) {
            previousButton
            flipButton
            nextButton
        }
        .padding()
    }
    
    private var previousButton: some View {
        Button(action: moveToPreviousCard) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(canMoveToPrevious ? subcategory.color : .secondary)
        }
        .disabled(!canMoveToPrevious)
    }
    
    private var flipButton: some View {
        Button(action: toggleFlip) {
            Image(systemName: isFlipped ? "eye.slash" : "eye")
                .font(.title2)
                .foregroundColor(subcategory.color)
        }
    }
    
    private var nextButton: some View {
        Button(action: moveToNextCard) {
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundColor(canMoveToNext ? subcategory.color : .secondary)
        }
        .disabled(!canMoveToNext)
    }
    
    // MARK: - Helper Properties
    private var canMoveToPrevious: Bool {
        currentIndex > 0
    }
    
    private var canMoveToNext: Bool {
        currentIndex < items.count - 1
    }
    
    private func toggleFlip() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isFlipped.toggle()
        }
    }
}
