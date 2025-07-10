import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager() // Singleton instance
    
    @Published var startTime: Date {
        didSet {
            UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "startTime")
        }
    }
    
    @Published var endTime: Date {
        didSet {
            UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "endTime")
        }
    }
    
    private init() {
        // Initialize with stored values or defaults
        let calendar = Calendar.current
        
        // Load startTime
        let startTimeInterval = UserDefaults.standard.double(forKey: "startTime")
        self.startTime = startTimeInterval > 0 ? Date(timeIntervalSince1970: startTimeInterval) :
        calendar.date(bySettingHour: 8, minute: 30, second: 0, of: Date())!
        
        // Load endTime
        let endTimeInterval = UserDefaults.standard.double(forKey: "endTime")
        self.endTime = endTimeInterval > 0 ? Date(timeIntervalSince1970: endTimeInterval) :
        calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
        
    }
}
