import Foundation
import SwiftUI

// MARK: - Codable Data Models for JSON Storage
struct LessonData: Codable {
    let categories: [LessonCategoryData]
    let subcategories: [SubcategoryData]
    let vocabularyItems: [VocabularyItemData]
    let idiomItems: [IdiomItemData]
    let phrasalVerbItems: [PhrasalVerbItemData]
    let sampleAnswers: [SampleAnswerData]
    let pronunciationItems: [PronunciationItemData]
}

// MARK: - New Vocabulary Data Models
struct NewVocabularyItemData: Codable, Identifiable {
    let id = UUID()
    let topic: String
    let subTopic: String
    let word: String
    let partOfSpeech: String
    let cefrLevel: String
    let examples: [String]
    
    enum CodingKeys: String, CodingKey {
        case topic, word, examples
        case subTopic = "sub_topic"
        case partOfSpeech = "part_of_speech"
        case cefrLevel = "cefr_level"
    }
}

struct LessonCategoryData: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let colorHex: String // Store color as hex string
    let lessonCount: Int
    let illustration: String
}

struct SubcategoryData: Codable, Identifiable {
    let id: String
    let categoryId: String
    let title: String
    let description: String
    let itemCount: Int
    let colorHex: String
    let order: Int // For sorting
}

struct VocabularyItemData: Codable, Identifiable {
    let id: String
    let subcategoryId: String
    let word: String
    let definition: String
    let example: String
    let difficulty: String
    let audioFileName: String?
    let order: Int
}

struct IdiomItemData: Codable, Identifiable {
    let id: String
    let subcategoryId: String
    let idiom: String
    let meaning: String
    let example: String
    let difficulty: String
    let order: Int
}

// MARK: - New Real Idioms Data Models
struct RealIdiomsData: Codable {
    let animals: [RealIdiomItem]?
    let body: [RealIdiomItem]?
    let buildings: [RealIdiomItem]?
    let clothing: [RealIdiomItem]?
    let colours: [RealIdiomItem]?
    let death: [RealIdiomItem]?
    let food: [RealIdiomItem]?
    let health: [RealIdiomItem]?
    let law: [RealIdiomItem]?
    let money: [RealIdiomItem]?
    let music: [RealIdiomItem]?
    let nature: [RealIdiomItem]?
    let numbers: [RealIdiomItem]?
    let plants: [RealIdiomItem]?
    let sports: [RealIdiomItem]?
    let structures: [RealIdiomItem]?
    let time: [RealIdiomItem]?
    let transport: [RealIdiomItem]?
    let weather: [RealIdiomItem]?
    let american: [RealIdiomItem]?
    let australian: [RealIdiomItem]?
    let british: [RealIdiomItem]?
    
    private enum CodingKeys: String, CodingKey {
        case animals = "Animals"
        case body = "Body"
        case buildings = "Buildings"
        case clothing = "Clothing"
        case colours = "Colours"
        case death = "Death"
        case food = "Food"
        case health = "Health"
        case law = "Law"
        case money = "Money"
        case music = "Music"
        case nature = "Nature"
        case numbers = "Numbers"
        case plants = "Plants"
        case sports = "Sports"
        case structures = "Structures"
        case time = "Time"
        case transport = "Transport"
        case weather = "Weather"
        case american = "American"
        case australian = "Australian"
        case british = "British"
    }
}

struct RealIdiomItem: Codable, Identifiable {
    let id = UUID()
    let idiom: String
    let meaning: String
    let examples: [String]
    
    enum CodingKeys: String, CodingKey {
        case idiom, meaning, examples
    }
}

struct PhrasalVerbItemData: Codable, Identifiable {
    let id: String
    let subcategoryId: String
    let verb: String
    let meaning: String
    let example: String
    let difficulty: String
    let order: Int
}

struct SampleAnswerData: Codable, Identifiable {
    let id: String
    let topicId: String
    let question: String
    let answer: String
    let keyVocabulary: [String]
    let tips: [String]
    let bandScore: String
}

struct SampleAnswerTopicData: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let category: String
    let difficulty: String
    let estimatedTime: String
    let order: Int
}

struct PronunciationItemData: Codable, Identifiable {
    let id: String
    let topicId: String
    let word: String
    let ipa: String
    let difficulty: String
    let commonMistakes: [String]
    let audioFileName: String?
    let example: String
    let order: Int
}

struct PronunciationTopicData: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let itemCount: Int
    let order: Int
}

// MARK: - User Progress Models
struct UserProgress: Codable {
    let userId: String
    var categoryProgress: [String: CategoryProgress] // categoryId -> progress
    var subcategoryProgress: [String: SubcategoryProgress] // subcategoryId -> progress
    var itemProgress: [String: ItemProgress] // itemId -> progress
    var streaks: [String: Int] // categoryId -> streak count
    var lastUpdated: Date
}

struct CategoryProgress: Codable {
    let categoryId: String
    var overallProgress: Double // 0.0 to 1.0
    let completedSubcategories: [String]
    let currentStreak: Int
    var lastStudiedDate: Date?
}

struct SubcategoryProgress: Codable {
    let subcategoryId: String
    var progress: Double // 0.0 to 1.0
    let completedItems: [String]
    let isUnlocked: Bool
    var lastStudiedDate: Date?
}

struct ItemProgress: Codable {
    let itemId: String
    let isCompleted: Bool
    let lastStudiedDate: Date?
    let studyCount: Int
    let masteryLevel: Int // 0-5 scale
}

// MARK: - New Vocabulary View Models
struct NewVocabularyItem: Identifiable {
    let id = UUID()
    let topic: String
    let subTopic: String
    let word: String
    let partOfSpeech: String
    let cefrLevel: CEFRLevel
    let examples: [String]
    
    init(from data: NewVocabularyItemData) {
        self.topic = data.topic
        self.subTopic = data.subTopic
        self.word = data.word
        self.partOfSpeech = data.partOfSpeech
        self.cefrLevel = CEFRLevel(rawValue: data.cefrLevel.uppercased()) ?? .B1
        self.examples = data.examples
    }
}

enum CEFRLevel: String, CaseIterable {
    case A1 = "A1"
    case A2 = "A2"
    case B1 = "B1"
    case B2 = "B2"
    case C1 = "C1"
    case C2 = "C2"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: UIColor {
        switch self {
        case .A1: return UIColor.systemGreen
        case .A2: return UIColor.systemBlue
        case .B1: return UIColor.systemOrange
        case .B2: return UIColor.systemPurple
        case .C1: return UIColor.systemRed
        case .C2: return UIColor.systemPink
        }
    }
    
    var swiftUIColor: Color {
        return Color(self.color)
    }
}

// MARK: - Real Idioms View Models
struct RealIdiomSubcategory: Identifiable {
    let id: String
    let title: String
    let description: String
    let itemCount: Int
    let color: Color
    let isLocked: Bool
    let items: [RealIdiomItemViewModel]
}

struct RealIdiomItemViewModel: Identifiable {
    let id = UUID()
    let idiom: String
    let meaning: String
    let examples: [String]
    let category: String
    let difficulty: String
    
    init(from realIdiomItem: RealIdiomItem, category: String) {
        self.idiom = realIdiomItem.idiom
        self.meaning = realIdiomItem.meaning
        self.examples = realIdiomItem.examples
        self.category = category
        self.difficulty = "Medium" // Default difficulty since it's not in the data
    }
}

// MARK: - Real Phrasal Verbs Data Models
struct RealPhrasalVerbsData: Codable {
    let climateChange: [RealPhrasalVerbItem]?
    let eating: [RealPhrasalVerbItem]?
    let work: [RealPhrasalVerbItem]?
    let sleep: [RealPhrasalVerbItem]?
    let feelings: [RealPhrasalVerbItem]?
    let travel: [RealPhrasalVerbItem]?
    let technology: [RealPhrasalVerbItem]?
    let healthFitness: [RealPhrasalVerbItem]?
    let money: [RealPhrasalVerbItem]?
    let education: [RealPhrasalVerbItem]?
    let friendship: [RealPhrasalVerbItem]?
    let housework: [RealPhrasalVerbItem]?
    let morningRoutine: [RealPhrasalVerbItem]?
    let business: [RealPhrasalVerbItem]?
    let clothes: [RealPhrasalVerbItem]?
    let sports: [RealPhrasalVerbItem]?
    
    private enum CodingKeys: String, CodingKey {
        case climateChange = "Climate Change"
        case eating = "Eating"
        case work = "Work"
        case sleep = "Sleep"
        case feelings = "Feelings"
        case travel = "Travel"
        case technology = "Technology"
        case healthFitness = "Health & Fitness"
        case money = "Money"
        case education = "Education"
        case friendship = "Friendship"
        case housework = "Housework"
        case morningRoutine = "Morning Routine"
        case business = "Business"
        case clothes = "Clothes"
        case sports = "Sports"
    }
}

struct RealPhrasalVerbItem: Codable, Identifiable {
    let id = UUID()
    let phrasalVerb: String
    let definition: String
    let examples: [String]
    
    enum CodingKeys: String, CodingKey {
        case phrasalVerb = "phrasal_verb"
        case definition, examples
    }
}

// MARK: - Real Phrasal Verbs View Models
struct RealPhrasalVerbSubcategory: Identifiable {
    let id: String
    let title: String
    let description: String
    let itemCount: Int
    let color: Color
    let isLocked: Bool
    let items: [RealPhrasalVerbItemViewModel]
}

struct RealPhrasalVerbItemViewModel: Identifiable {
    let id = UUID()
    let phrasalVerb: String
    let definition: String
    let examples: [String]
    let category: String
    let difficulty: String
    
    init(from realPhrasalVerbItem: RealPhrasalVerbItem, category: String) {
        self.phrasalVerb = realPhrasalVerbItem.phrasalVerb
        self.definition = realPhrasalVerbItem.definition
        self.examples = realPhrasalVerbItem.examples
        self.category = category
        self.difficulty = "Medium" // Default difficulty since it's not in the data
    }
}

