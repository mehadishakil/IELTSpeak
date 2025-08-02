//
//  DataValidator.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 2/8/25.
//


import Foundation

struct DataValidator {
    static func validateLessonData(_ data: LessonData) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        // Validate categories
        for category in data.categories {
            if category.title.isEmpty {
                errors.append(.emptyTitle("Category", category.id))
            }
            if category.lessonCount <= 0 {
                errors.append(.invalidCount("Category", category.id))
            }
        }
        
        // Validate subcategories
        for subcategory in data.subcategories {
            if subcategory.title.isEmpty {
                errors.append(.emptyTitle("Subcategory", subcategory.id))
            }
            
            // Check if category exists
            if !data.categories.contains(where: { $0.id == subcategory.categoryId }) {
                errors.append(.missingReference("Subcategory", subcategory.id, "category", subcategory.categoryId))
            }
        }
        
        // Validate vocabulary items
        for item in data.vocabularyItems {
            if item.word.isEmpty || item.definition.isEmpty {
                errors.append(.emptyContent("Vocabulary", item.id))
            }
            
            // Check if subcategory exists
            if !data.subcategories.contains(where: { $0.id == item.subcategoryId }) {
                errors.append(.missingReference("Vocabulary", item.id, "subcategory", item.subcategoryId))
            }
        }
        
        return errors
    }
}

enum ValidationError: LocalizedError {
    case emptyTitle(String, String)
    case invalidCount(String, String)
    case missingReference(String, String, String, String)
    case emptyContent(String, String)
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle(let type, let id):
            return "\(type) \(id) has empty title"
        case .invalidCount(let type, let id):
            return "\(type) \(id) has invalid count"
        case .missingReference(let type, let id, let refType, let refId):
            return "\(type) \(id) references missing \(refType) \(refId)"
        case .emptyContent(let type, let id):
            return "\(type) \(id) has empty content"
        }
    }
}