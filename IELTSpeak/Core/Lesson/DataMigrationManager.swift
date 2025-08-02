import Foundation

class DataMigrationManager {
    static let shared = DataMigrationManager()
    private let userDefaults = UserDefaults.standard
    private let currentDataVersion = "1.0"
    
    private init() {}
    
    func migrateIfNeeded() {
        let savedVersion = userDefaults.string(forKey: "dataVersion") ?? "0.0"
        
        if savedVersion != currentDataVersion {
            performMigration(from: savedVersion, to: currentDataVersion)
            userDefaults.set(currentDataVersion, forKey: "dataVersion")
        }
    }
    
    private func performMigration(from oldVersion: String, to newVersion: String) {
        print("Migrating data from version \(oldVersion) to \(newVersion)")
        
        switch oldVersion {
        case "0.0":
            // First time installation - clear any old mock data
            clearMockData()
        default:
            break
        }
    }
    
    private func clearMockData() {
        // Clear any old progress data that might conflict
        userDefaults.removeObject(forKey: "userProgress")
    }
}

// MARK: - Content Updates
extension DataMigrationManager {
    func checkForContentUpdates() {
        // This could check a remote server for updated content
        // For now, just validate local data
        
        do {
            let data = try LessonDataManager.shared.loadLessonDataFromJSON()
            let errors = DataValidator.validateLessonData(data)
            
            if !errors.isEmpty {
                print("Data validation errors found:")
                errors.forEach { print("- \($0.localizedDescription)") }
            }
        } catch {
            print("Failed to validate data: \(error)")
        }
    }
}
