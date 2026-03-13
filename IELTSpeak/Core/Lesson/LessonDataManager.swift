import Foundation
import SwiftUI

class LessonDataManager: ObservableObject {
    static let shared = LessonDataManager()
    
    @Published var categories: [LessonCategory] = []
    @Published var userProgress: UserProgress?
    @Published var isLoading = false
    @Published var error: DataError?
    @Published var newVocabularyItems: [NewVocabularyItem] = []
    @Published var realIdiomsSubcategories: [RealIdiomSubcategory] = []
    @Published var realPhrasalVerbsSubcategories: [RealPhrasalVerbSubcategory] = []
    @Published var sampleAnswersData: SampleAnswersData?
    
    private var lessonData: LessonData?
    private var rawNewVocabularyData: [NewVocabularyItemData] = []
    private var rawRealIdiomsData: RealIdiomsData?
    private var rawRealPhrasalVerbsData: RealPhrasalVerbsData?
    private let progressKey = "userProgress"
    
    private init() {
        loadData()
        loadUserProgress()
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        error = nil
        
        DispatchQueue.global(qos: .background).async {
            do {
                self.lessonData = try self.loadLessonDataFromJSON()
                
                // Load vocabulary data separately - don't fail if this doesn't work
                do {
                    self.rawNewVocabularyData = try self.loadNewVocabularyDataFromJSON()
                } catch {
                    print("Warning: Could not load vocabulary_data.json: \(error.localizedDescription)")
                    self.rawNewVocabularyData = []
                }
                
                // Load real idioms data separately
                do {
                    self.rawRealIdiomsData = try self.loadRealIdiomsDataFromJSON()
                } catch {
                    print("Warning: Could not load idioms_data.json: \(error.localizedDescription)")
                    self.rawRealIdiomsData = nil
                }
                
                // Load real phrasal verbs data separately
                do {
                    self.rawRealPhrasalVerbsData = try self.loadRealPhrasalVerbsDataFromJSON()
                } catch {
                    print("Warning: Could not load phrasal_verbs.json: \(error.localizedDescription)")
                    self.rawRealPhrasalVerbsData = nil
                }
                
                // Load sample answers data separately
                var loadedSampleAnswersData: SampleAnswersData?
                do {
                    loadedSampleAnswersData = try self.loadSampleAnswersDataFromJSON()
                } catch {
                    print("Warning: Could not load sample_answers.json: \(error.localizedDescription)")
                    loadedSampleAnswersData = nil
                }
                
                DispatchQueue.main.async {
                    self.categories = self.convertToViewModels()
                    self.newVocabularyItems = self.rawNewVocabularyData.map { NewVocabularyItem(from: $0) }
                    self.realIdiomsSubcategories = self.convertRealIdiomsToSubcategories()
                    self.realPhrasalVerbsSubcategories = self.convertRealPhrasalVerbsToSubcategories()
                    self.sampleAnswersData = loadedSampleAnswersData
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = .loadingFailed(error.localizedDescription)
                    self.isLoading = false
                }
            }
        }
    }
    
    func loadLessonDataFromJSON() throws -> LessonData {
        guard let path = Bundle.main.path(forResource: "lesson_data", ofType: "json"),
              let data = NSData(contentsOfFile: path) as Data? else {
            throw DataError.fileNotFound
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(LessonData.self, from: data)
    }
    
    func loadNewVocabularyDataFromJSON() throws -> [NewVocabularyItemData] {
        guard let path = Bundle.main.path(forResource: "vocabulary_data", ofType: "json") else {
            throw DataError.vocabularyFileNotFound
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            throw DataError.vocabularyFileNotFound
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([NewVocabularyItemData].self, from: data)
    }
    
    func loadRealIdiomsDataFromJSON() throws -> RealIdiomsData {
        guard let path = Bundle.main.path(forResource: "idioms_data", ofType: "json") else {
            throw DataError.idiomsFileNotFound
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            throw DataError.idiomsFileNotFound
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(RealIdiomsData.self, from: data)
    }
    
    func loadRealPhrasalVerbsDataFromJSON() throws -> RealPhrasalVerbsData {
        guard let path = Bundle.main.path(forResource: "phrasal_verbs", ofType: "json") else {
            throw DataError.phrasalVerbsFileNotFound
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            throw DataError.phrasalVerbsFileNotFound
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(RealPhrasalVerbsData.self, from: data)
    }
    
    func loadSampleAnswersDataFromJSON() throws -> SampleAnswersData {
        guard let path = Bundle.main.path(forResource: "sample_answers", ofType: "json") else {
            throw DataError.sampleAnswersFileNotFound
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            throw DataError.sampleAnswersFileNotFound
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(SampleAnswersData.self, from: data)
    }
    
    // MARK: - Data Conversion
    private func convertToViewModels() -> [LessonCategory] {
        guard let lessonData = lessonData else { return [] }
        
        return lessonData.categories.map { categoryData in
            let progress = userProgress?.categoryProgress[categoryData.id]?.overallProgress ?? 0.0
            let streak = userProgress?.streaks[categoryData.id] ?? 0
            
            return LessonCategory(
                id: categoryData.id,
                title: categoryData.title,
                description: categoryData.description,
                icon: categoryData.icon,
                color: Color(hex: categoryData.colorHex) ?? .blue,
                progress: progress,
                streak: streak,
                lessonCount: categoryData.lessonCount,
                illustration: categoryData.illustration
            )
        }
    }
    
    // MARK: - Subcategories
    func getSubcategories(for categoryId: String) -> [Subcategory] {
        if categoryId == "vocabulary" {
            return getVocabularyTopicSubcategories()
        } else if categoryId == "idioms" {
            return getRealIdiomsSubcategories()
        } else if categoryId == "phrasal-verbs" {
            return getRealPhrasalVerbsSubcategories()
        } else if categoryId == "sample-answers" {
            return getSampleAnswerSubcategories()
        }
        
        guard let lessonData = lessonData else { return [] }
        
        return lessonData.subcategories
            .filter { $0.categoryId == categoryId }
            .sorted { $0.order < $1.order }
            .map { subcategoryData in
                let progress = userProgress?.subcategoryProgress[subcategoryData.id]?.progress ?? 0.0
                let isLocked = !(
                    userProgress?
                        .subcategoryProgress[subcategoryData.id]?.isUnlocked ?? true
                )
                
                return Subcategory(
                    id: subcategoryData.id,
                    title: subcategoryData.title,
                    description: subcategoryData.description,
                    itemCount: subcategoryData.itemCount,
                    progress: progress,
                    color: Color(hex: subcategoryData.colorHex) ?? .blue,
                    isLocked: isLocked
                )
            }
    }
    
    // MARK: - Vocabulary Topic Subcategories
    private func getVocabularyTopicSubcategories() -> [Subcategory] {
        let topics = getUniqueTopics()
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .teal, .indigo, .mint, .cyan, .brown]
        
        return topics.enumerated().map { index, topic in
            let itemCount = newVocabularyItems.filter { $0.topic == topic }.count
            let color = colors[index % colors.count]
            
            // Create a readable title from topic name
            let title = formatTopicTitle(topic)
            let description = "Essential vocabulary for \(title.lowercased())"
            
            let subcategoryId = "vocab_\(topic)"
            let progress = userProgress?.subcategoryProgress[subcategoryId]?.progress ?? 0.0

            return Subcategory(
                id: subcategoryId,
                title: title,
                description: description,
                itemCount: itemCount,
                progress: progress,
                color: color,
                isLocked: false
            )
        }.sorted { $0.title < $1.title }
    }
    
    private func formatTopicTitle(_ topic: String) -> String {
        // Convert topic names like "transport-by-car-or-lorry" to "Transport by Car or Lorry"
        return topic.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    // MARK: - Content Items
    func getVocabularyItems(for subcategoryId: String) -> [VocabularyItem] {
        guard let lessonData = lessonData else { return [] }
        
        return lessonData.vocabularyItems
            .filter { $0.subcategoryId == subcategoryId }
            .sorted { $0.order < $1.order }
            .map { item in
                VocabularyItem(
                    id: item.id,
                    word: item.word,
                    definition: item.definition,
                    example: item.example,
                    difficulty: item.difficulty,
                    audioURL: item.audioFileName
                )
            }
    }
    
    func getIdiomItems(for subcategoryId: String) -> [IdiomItem] {
        guard let lessonData = lessonData else { return [] }
        
        return lessonData.idiomItems
            .filter { $0.subcategoryId == subcategoryId }
            .sorted { $0.order < $1.order }
            .map { item in
                IdiomItem(
                    id: item.id,
                    idiom: item.idiom,
                    meaning: item.meaning,
                    example: item.example,
                    difficulty: item.difficulty
                )
            }
    }
    
    func getPhrasalVerbItems(for subcategoryId: String) -> [PhrasalVerbItem] {
        guard let lessonData = lessonData else { return [] }
        
        return lessonData.phrasalVerbItems
            .filter { $0.subcategoryId == subcategoryId }
            .sorted { $0.order < $1.order }
            .map { item in
                PhrasalVerbItem(
                    id: item.id,
                    verb: item.verb,
                    meaning: item.meaning,
                    example: item.example,
                    difficulty: item.difficulty
                )
            }
    }
    
    func getSampleAnswerTopics() -> [SampleAnswerTopic] {
        guard let lessonData = lessonData else { return [] }
        
        // Group by topic and create topics
        let topics = Set(lessonData.sampleAnswers.map { $0.topicId })
        
        return topics.compactMap { topicId in
            // This would need corresponding topic data in your JSON
            // For now, creating basic topics
            SampleAnswerTopic(
                id: topicId,
                title: topicId.capitalized,
                description: "Sample answers for \(topicId)",
                category: "Part 1",
                difficulty: "Medium",
                estimatedTime: "2 min"
            )
        }
    }
    
    func getSampleAnswers(for topicId: String) -> [SampleAnswer] {
        guard let lessonData = lessonData else { return [] }
        
        return lessonData.sampleAnswers
            .filter { $0.topicId == topicId }
            .map { item in
                SampleAnswer(
                    id: item.id,
                    question: item.question,
                    answer: item.answer,
                    keyVocabulary: item.keyVocabulary,
                    tips: item.tips,
                    bandScore: item.bandScore
                )
            }
    }
    
    // MARK: - User Progress Management
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.userProgress = progress
        } else {
            // Create initial progress
            self.userProgress = createInitialProgress()
        }
    }
    
    private func saveUserProgress() {
        guard let progress = userProgress,
              let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: progressKey)
    }
    
    private func createInitialProgress() -> UserProgress {
        var categoryProgress: [String: CategoryProgress] = [:]
        var subcategoryProgress: [String: SubcategoryProgress] = [:]
        
        // Initialize with first subcategory unlocked for each category
        if let lessonData = lessonData {
            for category in lessonData.categories {
                categoryProgress[category.id] = CategoryProgress(
                    categoryId: category.id,
                    overallProgress: 0.0,
                    completedSubcategories: [],
                    currentStreak: 0,
                    lastStudiedDate: nil
                )
                
                // Unlock first subcategory
                let firstSubcategory = lessonData.subcategories
                    .filter { $0.categoryId == category.id }
                    .sorted { $0.order < $1.order }
                    .first
                
                if let firstSub = firstSubcategory {
                    subcategoryProgress[firstSub.id] = SubcategoryProgress(
                        subcategoryId: firstSub.id,
                        progress: 0.0,
                        completedItems: [],
                        isUnlocked: true,
                        lastStudiedDate: nil
                    )
                }
            }
        }
        
        return UserProgress(
            userId: "default_user",
            categoryProgress: categoryProgress,
            subcategoryProgress: subcategoryProgress,
            itemProgress: [:],
            streaks: [:],
            lastUpdated: Date()
        )
    }
    
    // MARK: - Progress Updates
    func markItemCompleted(itemId: String, subcategoryId: String, categoryId: String) {
        guard var progress = userProgress else { return }

        // Skip if already studied (avoid redundant saves)
        if progress.studiedItems?[itemId] != nil { return }

        // Track which subcategory this item belongs to
        var studiedItems = progress.studiedItems ?? [:]
        studiedItems[itemId] = subcategoryId
        progress.studiedItems = studiedItems

        // Update item progress
        progress.itemProgress[itemId] = ItemProgress(
            itemId: itemId,
            isCompleted: true,
            lastStudiedDate: Date(),
            studyCount: (progress.itemProgress[itemId]?.studyCount ?? 0) + 1,
            masteryLevel: min((progress.itemProgress[itemId]?.masteryLevel ?? 0) + 1, 5)
        )

        // Update subcategory progress
        updateSubcategoryProgress(subcategoryId: subcategoryId, categoryId: categoryId, progress: &progress)

        // Update category progress
        updateCategoryProgress(categoryId: categoryId, progress: &progress)

        progress.lastUpdated = Date()
        self.userProgress = progress
        saveUserProgress()

        // Defer category rebuild to avoid blocking swipe animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.categories = self?.convertToViewModels() ?? []
        }
    }

    func isItemStudied(_ stableId: String) -> Bool {
        return userProgress?.studiedItems?[stableId] != nil
    }

    private func getTotalItemCount(for subcategoryId: String, categoryId: String) -> Int {
        // New vocabulary topics (format: vocab_topicname)
        if subcategoryId.hasPrefix("vocab_") {
            let topic = String(subcategoryId.dropFirst(6))
            return newVocabularyItems.filter { $0.topic == topic }.count
        }
        // Real idioms
        if subcategoryId.hasPrefix("real_idioms_") {
            return realIdiomsSubcategories.first { $0.id == subcategoryId }?.itemCount ?? 0
        }
        // Real phrasal verbs
        if subcategoryId.hasPrefix("real_phrasal_verbs_") {
            return realPhrasalVerbsSubcategories.first { $0.id == subcategoryId }?.itemCount ?? 0
        }
        // Legacy lesson_data.json items
        guard let lessonData = lessonData else { return 0 }
        return lessonData.vocabularyItems.filter { $0.subcategoryId == subcategoryId }.count +
               lessonData.idiomItems.filter { $0.subcategoryId == subcategoryId }.count +
               lessonData.phrasalVerbItems.filter { $0.subcategoryId == subcategoryId }.count
    }

    private func updateSubcategoryProgress(subcategoryId: String, categoryId: String, progress: inout UserProgress) {
        let totalItems = getTotalItemCount(for: subcategoryId, categoryId: categoryId)

        // Count completed items for this subcategory using the studiedItems map
        let studiedItems = progress.studiedItems ?? [:]
        let completedItems = studiedItems.filter { $0.value == subcategoryId }.count

        let progressPercentage = totalItems > 0 ? Double(completedItems) / Double(totalItems) : 0.0

        var subProgress = progress.subcategoryProgress[subcategoryId] ?? SubcategoryProgress(
            subcategoryId: subcategoryId,
            progress: 0.0,
            completedItems: [],
            isUnlocked: true,
            lastStudiedDate: nil
        )

        subProgress.progress = min(progressPercentage, 1.0)
        subProgress.lastStudiedDate = Date()
        progress.subcategoryProgress[subcategoryId] = subProgress
    }

    private func updateCategoryProgress(categoryId: String, progress: inout UserProgress) {
        // Get all subcategory IDs for this category
        let subcategoryIds = getAllSubcategoryIds(for: categoryId)
        guard !subcategoryIds.isEmpty else { return }

        // Sum total items and completed items across all subcategories
        var totalItems = 0
        var completedItems = 0
        let studiedItems = progress.studiedItems ?? [:]

        for subId in subcategoryIds {
            totalItems += getTotalItemCount(for: subId, categoryId: categoryId)
            completedItems += studiedItems.filter { $0.value == subId }.count
        }

        let overallProgress = totalItems > 0 ? Double(completedItems) / Double(totalItems) : 0.0

        var catProgress = progress.categoryProgress[categoryId] ?? CategoryProgress(
            categoryId: categoryId,
            overallProgress: 0.0,
            completedSubcategories: [],
            currentStreak: 0,
            lastStudiedDate: nil
        )

        catProgress.overallProgress = min(overallProgress, 1.0)
        catProgress.lastStudiedDate = Date()
        progress.categoryProgress[categoryId] = catProgress
    }

    private func getAllSubcategoryIds(for categoryId: String) -> [String] {
        switch categoryId {
        case "vocabulary":
            return getUniqueTopics().map { "vocab_\($0)" }
        case "idioms":
            return realIdiomsSubcategories.map { $0.id }
        case "phrasal-verbs":
            return realPhrasalVerbsSubcategories.map { $0.id }
        default:
            guard let lessonData = lessonData else { return [] }
            return lessonData.subcategories.filter { $0.categoryId == categoryId }.map { $0.id }
        }
    }

    // MARK: - Direct Count Methods for Leaderboard
    func getStudiedVocabularyCount() -> Int {
        guard let progress = userProgress, let studiedItems = progress.studiedItems else { return 0 }
        return studiedItems.filter { $0.value.hasPrefix("vocab_") }.count
    }

    func getStudiedIdiomsCount() -> Int {
        guard let progress = userProgress, let studiedItems = progress.studiedItems else { return 0 }
        return studiedItems.filter { $0.value.hasPrefix("real_idioms_") }.count
    }

    func getStudiedPhrasalVerbsCount() -> Int {
        guard let progress = userProgress, let studiedItems = progress.studiedItems else { return 0 }
        return studiedItems.filter { $0.value.hasPrefix("real_phrasal_verbs_") }.count
    }

    func getStudiedCountForSubcategory(_ subcategoryId: String) -> Int {
        guard let progress = userProgress, let studiedItems = progress.studiedItems else { return 0 }
        return studiedItems.filter { $0.value == subcategoryId }.count
    }

    // MARK: - New Vocabulary Methods
    func getUniqueTopics() -> [String] {
        return Array(Set(newVocabularyItems.map { $0.topic })).sorted()
    }
    
    func getUniqueSubTopics(for topic: String? = nil) -> [String] {
        let items = topic == nil ? newVocabularyItems : newVocabularyItems.filter { $0.topic == topic }
        return Array(Set(items.map { $0.subTopic })).sorted()
    }
    
    // MARK: - Sample Answers Subcategories
    func getSampleAnswerSubcategories() -> [Subcategory] {
        // Return basic subcategories even if data isn't loaded yet
        let part1Count = sampleAnswersData?.part_1_sample_answers.reduce(0) { $0 + $1.questions.count } ?? 0
        let part2Count = sampleAnswersData?.part_2_sample_answers.count ?? 0
        let part3Count = sampleAnswersData?.part_3_sample_answers.reduce(0) { $0 + $1.questions.count } ?? 0

        let part1Studied = getStudiedCountForSubcategory("sample-answers-part1")
        let part2Studied = getStudiedCountForSubcategory("sample-answers-part2")
        let part3Studied = getStudiedCountForSubcategory("sample-answers-part3")

        let part1Progress = part1Count > 0 ? Double(part1Studied) / Double(part1Count) : 0.0
        let part2Progress = part2Count > 0 ? Double(part2Studied) / Double(part2Count) : 0.0
        let part3Progress = part3Count > 0 ? Double(part3Studied) / Double(part3Count) : 0.0

        return [
            Subcategory(
                id: "sample-answers-part1",
                title: "Part 1: Introduction & Interview",
                description: "Personal questions about familiar topics",
                itemCount: part1Count,
                progress: part1Progress,
                color: .blue,
                isLocked: false
            ),
            Subcategory(
                id: "sample-answers-part2",
                title: "Part 2: Individual Long Turn",
                description: "2-minute talk on a given topic",
                itemCount: part2Count,
                progress: part2Progress,
                color: .green,
                isLocked: false
            ),
            Subcategory(
                id: "sample-answers-part3",
                title: "Part 3: Two-way Discussion",
                description: "Abstract and complex questions",
                itemCount: part3Count,
                progress: part3Progress,
                color: .purple,
                isLocked: false
            )
        ]
    }
    
    func getFilteredVocabulary(topic: String? = nil, subTopic: String? = nil, cefrLevel: CEFRLevel? = nil) -> [NewVocabularyItem] {
        var filtered = newVocabularyItems
        
        if let topic = topic {
            filtered = filtered.filter { $0.topic == topic }
        }
        
        if let subTopic = subTopic {
            filtered = filtered.filter { $0.subTopic == subTopic }
        }
        
        if let cefrLevel = cefrLevel {
            filtered = filtered.filter { $0.cefrLevel == cefrLevel }
        }
        
        return filtered.sorted { $0.word < $1.word }
    }
    
    // MARK: - Real Idioms Methods
    private func convertRealIdiomsToSubcategories() -> [RealIdiomSubcategory] {
        guard let realIdiomsData = rawRealIdiomsData else { return [] }
        
        var subcategories: [RealIdiomSubcategory] = []
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .teal, .indigo, .mint, .cyan, .brown]
        var colorIndex = 0
        
        let mirror = Mirror(reflecting: realIdiomsData)
        for child in mirror.children {
            guard let categoryItems = child.value as? [RealIdiomItem],
                  !categoryItems.isEmpty,
                  let categoryName = child.label else { continue }
            
            let viewModelItems = categoryItems.map { item in
                RealIdiomItemViewModel(from: item, category: categoryName.capitalized)
            }
            
            let subcategory = RealIdiomSubcategory(
                id: "real_idioms_\(categoryName)",
                title: formatCategoryTitle(categoryName),
                description: "Common idioms related to \(formatCategoryTitle(categoryName).lowercased())",
                itemCount: categoryItems.count,
                color: colors[colorIndex % colors.count],
                isLocked: false,
                items: viewModelItems
            )
            
            subcategories.append(subcategory)
            colorIndex += 1
        }
        
        return subcategories.sorted { $0.title < $1.title }
    }
    
    private func getRealIdiomsSubcategories() -> [Subcategory] {
        return realIdiomsSubcategories.map { realSubcategory in
            let progress = userProgress?.subcategoryProgress[realSubcategory.id]?.progress ?? 0.0
            let isLocked = !(userProgress?.subcategoryProgress[realSubcategory.id]?.isUnlocked ?? true)
            
            return Subcategory(
                id: realSubcategory.id,
                title: realSubcategory.title,
                description: realSubcategory.description,
                itemCount: realSubcategory.itemCount,
                progress: progress,
                color: realSubcategory.color,
                isLocked: isLocked
            )
        }
    }
    
    func getRealIdiomItems(for subcategoryId: String) -> [RealIdiomItemViewModel] {
        return realIdiomsSubcategories.first { $0.id == subcategoryId }?.items ?? []
    }
    
    private func formatCategoryTitle(_ category: String) -> String {
        return category.capitalized
    }
    
    // MARK: - Real Phrasal Verbs Methods
    private func convertRealPhrasalVerbsToSubcategories() -> [RealPhrasalVerbSubcategory] {
        guard let realPhrasalVerbsData = rawRealPhrasalVerbsData else { return [] }
        
        var subcategories: [RealPhrasalVerbSubcategory] = []
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .teal, .indigo, .mint, .cyan, .brown, .gray]
        var colorIndex = 0
        
        let mirror = Mirror(reflecting: realPhrasalVerbsData)
        for child in mirror.children {
            guard let categoryItems = child.value as? [RealPhrasalVerbItem],
                  !categoryItems.isEmpty,
                  let categoryName = child.label else { continue }
            
            let viewModelItems = categoryItems.map { item in
                RealPhrasalVerbItemViewModel(from: item, category: formatPhrasalVerbCategoryTitle(categoryName))
            }
            
            let subcategory = RealPhrasalVerbSubcategory(
                id: "real_phrasal_verbs_\(categoryName)",
                title: formatPhrasalVerbCategoryTitle(categoryName),
                description: "Essential phrasal verbs for \(formatPhrasalVerbCategoryTitle(categoryName).lowercased())",
                itemCount: categoryItems.count,
                color: colors[colorIndex % colors.count],
                isLocked: false,
                items: viewModelItems
            )
            
            subcategories.append(subcategory)
            colorIndex += 1
        }
        
        return subcategories.sorted { $0.title < $1.title }
    }
    
    private func getRealPhrasalVerbsSubcategories() -> [Subcategory] {
        return realPhrasalVerbsSubcategories.map { realSubcategory in
            let progress = userProgress?.subcategoryProgress[realSubcategory.id]?.progress ?? 0.0
            let isLocked = !(userProgress?.subcategoryProgress[realSubcategory.id]?.isUnlocked ?? true)
            
            return Subcategory(
                id: realSubcategory.id,
                title: realSubcategory.title,
                description: realSubcategory.description,
                itemCount: realSubcategory.itemCount,
                progress: progress,
                color: realSubcategory.color,
                isLocked: isLocked
            )
        }
    }
    
    func getRealPhrasalVerbItems(for subcategoryId: String) -> [RealPhrasalVerbItemViewModel] {
        return realPhrasalVerbsSubcategories.first { $0.id == subcategoryId }?.items ?? []
    }
    
    private func formatPhrasalVerbCategoryTitle(_ category: String) -> String {
        // Handle specific cases for better formatting
        switch category {
        case "climateChange":
            return "Climate Change"
        case "healthFitness":
            return "Health & Fitness"
        case "morningRoutine":
            return "Morning Routine"
        default:
            return category.capitalized
        }
    }
}

// MARK: - Error Handling
enum DataError: LocalizedError {
    case fileNotFound
    case vocabularyFileNotFound
    case idiomsFileNotFound
    case phrasalVerbsFileNotFound
    case sampleAnswersFileNotFound
    case loadingFailed(String)
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Lesson data file not found"
        case .vocabularyFileNotFound:
            return "Vocabulary data file not found"
        case .idiomsFileNotFound:
            return "Idioms data file not found"
        case .phrasalVerbsFileNotFound:
            return "Phrasal verbs data file not found"
        case .sampleAnswersFileNotFound:
            return "Sample answers data file not found"
        case .loadingFailed(let message):
            return "Failed to load data: \(message)"
        case .parsingError:
            return "Failed to parse lesson data"
        }
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
