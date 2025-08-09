import SwiftUI

struct NewVocabularyView: View {
    let preSelectedTopic: String?
    
    @StateObject private var dataManager = LessonDataManager.shared
    @State private var selectedTopic: String? = nil
    @State private var selectedSubTopic: String? = nil
    @State private var selectedCEFRLevel: CEFRLevel? = nil
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var currentIndex = 0
    @State private var isFlipped = false
    
    init(topic: String? = nil) {
        self.preSelectedTopic = topic
    }
    
    private var filteredVocabulary: [NewVocabularyItem] {
        // If we have a preselected topic, filter by it first
        let baseFiltered = if let preSelectedTopic = preSelectedTopic {
            dataManager.newVocabularyItems.filter { $0.topic == preSelectedTopic }
        } else {
            selectedTopic == nil ? dataManager.newVocabularyItems : 
                                 dataManager.newVocabularyItems.filter { $0.topic == selectedTopic }
        }
        
        let subTopicFiltered = selectedSubTopic == nil ? baseFiltered :
                              baseFiltered.filter { $0.subTopic == selectedSubTopic }
        
        let cefrFiltered = selectedCEFRLevel == nil ? subTopicFiltered :
                          subTopicFiltered.filter { $0.cefrLevel == selectedCEFRLevel }
        
        let searchFiltered = searchText.isEmpty ? cefrFiltered :
                           cefrFiltered.filter { $0.word.localizedCaseInsensitiveContains(searchText) }
        
        return searchFiltered.sorted { $0.word < $1.word }
    }
    
    private var uniqueTopics: [String] {
        if preSelectedTopic != nil {
            return [] // Don't show topic filter if we have a preselected topic
        }
        return dataManager.getUniqueTopics()
    }
    
    private var uniqueSubTopics: [String] {
        let topicToUse = preSelectedTopic ?? selectedTopic
        return dataManager.getUniqueSubTopics(for: topicToUse)
    }
    
    private var navigationTitle: String {
        if let preSelectedTopic = preSelectedTopic {
            return formatTopicTitle(preSelectedTopic)
        }
        return "Vocabulary"
    }
    
    private func formatTopicTitle(_ topic: String) -> String {
        return topic.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Header
                headerView
                
                if dataManager.isLoading {
                    loadingView
                } else if filteredVocabulary.isEmpty {
                    emptyStateView
                } else {
                    // Content View - Card or List
                    contentView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingFilters) {
                filterSheet
            }
            .onAppear {
                if dataManager.newVocabularyItems.isEmpty {
                    dataManager.loadData()
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 16) {

            
            // Filter chips and button
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            title: selectedTopic ?? "All Topics",
                            isSelected: selectedTopic != nil,
                            color: .blue
                        ) {
                            selectedTopic = nil
                            selectedSubTopic = nil
                        }
                        
                        if selectedTopic != nil {
                            FilterChip(
                                title: selectedSubTopic ?? "All Subtopics",
                                isSelected: selectedSubTopic != nil,
                                color: .green
                            ) {
                                selectedSubTopic = nil
                            }
                        }
                        
                        FilterChip(
                            title: selectedCEFRLevel?.displayName ?? "All Levels",
                            isSelected: selectedCEFRLevel != nil,
                            color: .purple
                        ) {
                            selectedCEFRLevel = nil
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Button(action: { showingFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
                .padding(.trailing)
            }
            
            // Results count
            HStack {
                Text("\(filteredVocabulary.count) words")
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !filteredVocabulary.isEmpty {
                    Text("\(currentIndex + 1) of \(filteredVocabulary.count)")
                        .font(.custom("Fredoka-Medium", size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 20) {
            // Cards
            TabView(selection: $currentIndex) {
                ForEach(Array(filteredVocabulary.enumerated()), id: \.element.id) { index, item in
                    NewVocabularyCard(item: item, isFlipped: $isFlipped)
                        .padding(.horizontal, 20)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isFlipped.toggle()
                }
            }
            .onChange(of: currentIndex) { _ in
                isFlipped = false
            }
            
            controlButtons
            
            Spacer()
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 40) {
            previousButton
            flipButton
            nextButton
        }
        .padding(.horizontal, 20)
    }
    
    private var previousButton: some View {
        Button(action: moveToPreviousCard) {
            Image(systemName: "chevron.left")
                .font(.title2)
                .foregroundColor(canMoveToPrevious ? .accentColor : .secondary)
        }
        .disabled(!canMoveToPrevious)
    }
    
    private var flipButton: some View {
        Button(action: toggleFlip) {
            Image(systemName: isFlipped ? "eye.slash" : "eye")
                .font(.title2)
                .foregroundColor(.accentColor)
        }
    }
    
    private var nextButton: some View {
        Button(action: moveToNextCard) {
            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundColor(canMoveToNext ? .accentColor : .secondary)
        }
        .disabled(!canMoveToNext)
    }
    
    // MARK: - Helper Properties
    private var canMoveToPrevious: Bool {
        currentIndex > 0
    }
    
    private var canMoveToNext: Bool {
        currentIndex < filteredVocabulary.count - 1
    }
    
    // MARK: - Navigation Methods
    private func moveToPreviousCard() {
        guard canMoveToPrevious else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentIndex -= 1
            isFlipped = false
        }
    }
    
    private func moveToNextCard() {
        guard canMoveToNext else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentIndex += 1
            isFlipped = false
        }
    }
    
    private func toggleFlip() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isFlipped.toggle()
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading vocabulary...")
                .font(.custom("Fredoka-SemiBold", size: 18))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            Text("No vocabulary found")
                .font(.custom("Fredoka-SemiBold", size: 24))
                .foregroundColor(.primary)
            
            Text("Try adjusting your filters or search terms")
                .font(.custom("Fredoka-Medium", size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Filters") {
                searchText = ""
                selectedTopic = nil
                selectedSubTopic = nil
                selectedCEFRLevel = nil
            }
            .font(.custom("Fredoka-SemiBold", size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.accentColor)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Filter Sheet
    private var filterSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Topic Filter (only show if no preselected topic)
                if preSelectedTopic == nil {
                    FilterSection(title: "Topic") {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 120), spacing: 12)
                        ], spacing: 12) {
                            ForEach(uniqueTopics, id: \.self) { topic in
                                FilterButton(
                                    title: topic.capitalized,
                                    isSelected: selectedTopic == topic,
                                    color: .blue
                                ) {
                                    selectedTopic = selectedTopic == topic ? nil : topic
                                    selectedSubTopic = nil
                                }
                            }
                        }
                    }
                }
                
                // Subtopic Filter
                if (preSelectedTopic != nil || selectedTopic != nil) && !uniqueSubTopics.isEmpty {
                    FilterSection(title: "Subtopic") {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 150), spacing: 12)
                        ], spacing: 12) {
                            ForEach(uniqueSubTopics, id: \.self) { subTopic in
                                FilterButton(
                                    title: subTopic,
                                    isSelected: selectedSubTopic == subTopic,
                                    color: .green
                                ) {
                                    selectedSubTopic = selectedSubTopic == subTopic ? nil : subTopic
                                }
                            }
                        }
                    }
                }
                
                // CEFR Level Filter
                FilterSection(title: "CEFR Level") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 80), spacing: 12)
                    ], spacing: 12) {
                        ForEach(CEFRLevel.allCases, id: \.self) { level in
                            FilterButton(
                                title: level.displayName,
                                isSelected: selectedCEFRLevel == level,
                                color: level.swiftUIColor
                            ) {
                                selectedCEFRLevel = selectedCEFRLevel == level ? nil : level
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Clear All Button
                Button("Clear All Filters") {
                    selectedTopic = nil
                    selectedSubTopic = nil
                    selectedCEFRLevel = nil
                    searchText = ""
                }
                .font(.custom("Fredoka-SemiBold", size: 16))
                .foregroundColor(.red)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(20)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    showingFilters = false
                    currentIndex = 0
                }
            )
        }
    }
}

// MARK: - Supporting Views

struct NewVocabularyCard: View {
    let item: NewVocabularyItem
    @Binding var isFlipped: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if !isFlipped {
                // Front side - Word
                VStack(spacing: 16) {
                    Text(item.word.capitalized)
                        .font(.custom("Fredoka-SemiBold", size: 36))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 12) {
                        Text(item.partOfSpeech)
                            .font(.custom("Fredoka-Medium", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .clipShape(Capsule())
                        
                        Text(item.cefrLevel.displayName)
                            .font(.custom("Fredoka-Medium", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(item.cefrLevel.swiftUIColor)
                            .clipShape(Capsule())
                    }
                    
                    VStack(spacing: 4) {
                        Text(item.topic.capitalized)
                            .font(.custom("Fredoka-Medium", size: 16))
                            .foregroundColor(.secondary)
                        
                        Text(item.subTopic)
                            .font(.custom("Fredoka-Medium", size: 14))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text("Tap to see examples")
                        .font(.custom("Fredoka-Medium", size: 16))
                        .foregroundColor(.secondary)
                }
            } else {
                // Back side - Examples
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Examples")
                            .font(.custom("Fredoka-SemiBold", size: 24))
                            .foregroundColor(.primary)
                        
                        ForEach(Array(item.examples.enumerated()), id: \.offset) { index, example in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Example \(index + 1):")
                                    .font(.custom("Fredoka-SemiBold", size: 14))
                                    .foregroundColor(.secondary)
                                
                                Text(example)
                                    .font(.custom("Fredoka-Medium", size: 16))
                                    .foregroundColor(.primary)
                                    .lineSpacing(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Spacer()
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .frame(height: 400)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(isSelected ? .white : color)
                
                if isSelected {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color, lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.custom("Fredoka-SemiBold", size: 14))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? color : color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(color, lineWidth: isSelected ? 0 : 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Fredoka-SemiBold", size: 20))
                .foregroundColor(.primary)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
struct NewVocabularyView_Previews: PreviewProvider {
    static var previews: some View {
        NewVocabularyView(topic: nil)
    }
}
