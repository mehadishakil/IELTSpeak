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
    @State private var dragOffset: CGFloat = 0

    init(topic: String? = nil) {
        self.preSelectedTopic = topic
    }

    private var filteredVocabulary: [NewVocabularyItem] {
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
            return []
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
                headerView

                if dataManager.isLoading {
                    loadingView
                } else if filteredVocabulary.isEmpty {
                    emptyStateView
                } else {
                    contentView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 245/255, green: 245/255, blue: 245/255))
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
        HStack {
            if !filteredVocabulary.isEmpty {
                Text("\(currentIndex + 1) of \(filteredVocabulary.count)")
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { showingFilters = true }) {
                Text("Filter")
                    .font(.custom("Fredoka-Medium", size: 15))
                    .foregroundColor(hasActiveFilters ? Color(red: 100/255, green: 96/255, blue: 180/255) : .secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private var hasActiveFilters: Bool {
        selectedTopic != nil || selectedSubTopic != nil || selectedCEFRLevel != nil
    }

    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 0) {

            // Card area
            ZStack {
                if !filteredVocabulary.isEmpty {
                    NewVocabularyCard(
                        item: filteredVocabulary[currentIndex],
                        isFlipped: $isFlipped,
                        currentIndex: currentIndex,
                        totalCount: filteredVocabulary.count
                    )
                    .id(currentIndex)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 60
                                if value.translation.width < -threshold && canMoveToNext {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        dragOffset = -UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        currentIndex += 1
                                        isFlipped = false
                                        dragOffset = 0
                                    }
                                } else if value.translation.width > threshold && canMoveToPrevious {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        dragOffset = UIScreen.main.bounds.width
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        currentIndex -= 1
                                        isFlipped = false
                                        dragOffset = 0
                                    }
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                }
            }
            .padding(.horizontal, 20)
            .frame(maxHeight: 400)

//            Spacer(minLength: 8)

            // Control buttons
            controlButtons
                .padding(.bottom, 48)
                .padding(.top, 16)
        }
    }

    // MARK: - Control Buttons
    private var controlButtons: some View {
        HStack(spacing: 0) {
            // Previous
            Button(action: moveToPreviousCard) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(canMoveToPrevious ? .primary : .secondary.opacity(0.4))
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(Color(red: 245/255, green: 245/255, blue: 245/255))
                            .shadow(color: .black.opacity(canMoveToPrevious ? 0.08 : 0), radius: 4, y: 2)
                    )
            }
            .disabled(!canMoveToPrevious)

            Spacer()

            // Flip
            Button(action: toggleFlip) {
                HStack(spacing: 8) {
                    Image(systemName: isFlipped ? "character.book.closed" : "text.quote")
                        .font(.system(size: 16, weight: .semibold))
                    Text(isFlipped ? "Word" : "Examples")
                        .font(.custom("Fredoka-Medium", size: 15))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 130/255, green: 126/255, blue: 210/255), Color(red: 100/255, green: 96/255, blue: 180/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 100/255, green: 96/255, blue: 180/255).opacity(0.4), radius: 8, y: 4)
                )
            }

            Spacer()

            // Next
            Button(action: moveToNextCard) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(canMoveToNext ? .primary : .secondary.opacity(0.4))
                    .frame(width: 52, height: 52)
                    .background(
                        Circle()
                            .fill(Color(red: 245/255, green: 245/255, blue: 245/255))
                            .shadow(color: .black.opacity(canMoveToNext ? 0.08 : 0), radius: 4, y: 2)
                    )
            }
            .disabled(!canMoveToNext)
        }
        .padding(.horizontal, 32)
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
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentIndex -= 1
            isFlipped = false
        }
    }

    private func moveToNextCard() {
        guard canMoveToNext else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentIndex += 1
            isFlipped = false
        }
    }

    private func toggleFlip() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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

// MARK: - Flashcard

struct NewVocabularyCard: View {
    let item: NewVocabularyItem
    @Binding var isFlipped: Bool
    let currentIndex: Int
    let totalCount: Int

    private let cardGradientFront = LinearGradient(
        colors: [Color.white, Color(red: 248/255, green: 247/255, blue: 255/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let accentPurple = Color(red: 100/255, green: 96/255, blue: 180/255)

    var body: some View {
        ZStack {
            // Front
            frontSide
                .opacity(isFlipped ? 0 : 1)

            // Back
            backSide
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white)
                .shadow(color: accentPurple.opacity(0.12), radius: 20, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(accentPurple.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }

    // MARK: - Front Side
    private var frontSide: some View {
        VStack(spacing: 0) {
            // Top accent bar
            HStack {
                Text(item.topic.capitalized)
                    .font(.custom("Fredoka-SemiBold", size: 16))
                    .foregroundColor(accentPurple.opacity(0.7))

                Spacer()

                Text(item.subTopic)
                    .font(.custom("Fredoka-Medium", size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer()

            // Word
            VStack(spacing: 16) {
                // Decorative letter circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [accentPurple.opacity(0.15), item.cefrLevel.swiftUIColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)

                    Text(String(item.word.prefix(1)).uppercased())
                        .font(.custom("Fredoka-Bold", size: 28))
                        .foregroundColor(accentPurple)
                }

                Text(item.word.capitalized)
                    .font(.custom("Fredoka-Bold", size: 34))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                // Badges
                HStack(spacing: 10) {
                    BadgePill(text: item.partOfSpeech, color: accentPurple)
                    BadgePill(text: item.cefrLevel.displayName, color: item.cefrLevel.swiftUIColor)
                }
            }

            Spacer()

            // Bottom hint
            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 13))
                Text("Tap to see examples")
                    .font(.custom("Fredoka-Medium", size: 14))
            }
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Back Side
    private var backSide: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(item.word.capitalized)
                    .font(.custom("Fredoka-SemiBold", size: 20))
                    .foregroundColor(accentPurple)

                Spacer()

                BadgePill(text: item.cefrLevel.displayName, color: item.cefrLevel.swiftUIColor)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)

            Divider()
                .padding(.horizontal, 24)

            // Examples
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(item.examples.enumerated()), id: \.offset) { index, example in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.custom("Fredoka-Bold", size: 14))
                                .foregroundColor(.white)
                                .frame(width: 26, height: 26)
                                .background(
                                    Circle()
                                        .fill(accentPurple.opacity(0.7 + Double(index) * 0.1))
                                )

                            Text(example)
                                .font(.custom("Fredoka-Medium", size: 16))
                                .foregroundColor(.primary.opacity(0.85))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }

            Spacer(minLength: 0)

            // Bottom hint
            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                    .font(.system(size: 13))
                Text("Tap to see word")
                    .font(.custom("Fredoka-Medium", size: 14))
            }
            .foregroundColor(.secondary.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Badge Pill
struct BadgePill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.custom("Fredoka-Medium", size: 13))
            .foregroundColor(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
            )
    }
}

// MARK: - Supporting Views

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
