import Foundation

// Simple validator to test phrasal verbs data loading
struct PhrasalVerbsDataValidator {
    
    static func validatePhrasalVerbsData() -> Bool {
        guard let path = Bundle.main.path(forResource: "phrasal_verbs", ofType: "json") else {
            print("❌ phrasal_verbs.json not found in bundle")
            return false
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            print("❌ Could not read phrasal_verbs.json")
            return false
        }
        
        do {
            let realPhrasalVerbsData = try JSONDecoder().decode(RealPhrasalVerbsData.self, from: data)
            
            // Count total phrasal verbs
            var totalPhrasalVerbs = 0
            let mirror = Mirror(reflecting: realPhrasalVerbsData)
            
            for child in mirror.children {
                if let phrasalVerbArray = child.value as? [RealPhrasalVerbItem] {
                    totalPhrasalVerbs += phrasalVerbArray.count
                    print("✅ \(child.label?.capitalized ?? "Unknown"): \(phrasalVerbArray.count) phrasal verbs")
                }
            }
            
            print("✅ Total phrasal verbs loaded: \(totalPhrasalVerbs)")
            return true
            
        } catch {
            print("❌ Failed to decode phrasal_verbs.json: \(error.localizedDescription)")
            return false
        }
    }
}