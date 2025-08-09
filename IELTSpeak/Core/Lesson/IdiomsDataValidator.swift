import Foundation

// Simple validator to test idioms data loading
struct IdiomsDataValidator {
    
    static func validateIdiomsData() -> Bool {
        guard let path = Bundle.main.path(forResource: "idioms_data", ofType: "json") else {
            print("❌ idioms_data.json not found in bundle")
            return false
        }
        
        guard let data = NSData(contentsOfFile: path) as Data? else {
            print("❌ Could not read idioms_data.json")
            return false
        }
        
        do {
            let realIdiomsData = try JSONDecoder().decode(RealIdiomsData.self, from: data)
            
            // Count total idioms
            var totalIdioms = 0
            let mirror = Mirror(reflecting: realIdiomsData)
            
            for child in mirror.children {
                if let idiomArray = child.value as? [RealIdiomItem] {
                    totalIdioms += idiomArray.count
                    print("✅ \(child.label?.capitalized ?? "Unknown"): \(idiomArray.count) idioms")
                }
            }
            
            print("✅ Total idioms loaded: \(totalIdioms)")
            return true
            
        } catch {
            print("❌ Failed to decode idioms_data.json: \(error.localizedDescription)")
            return false
        }
    }
}