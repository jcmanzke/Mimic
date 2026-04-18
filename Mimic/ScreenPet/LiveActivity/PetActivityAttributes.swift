import ActivityKit
import Foundation

struct PetActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var health: Double // 0.0 - 1.0
        var petState: String // "Happy", "Sad", etc.
        
        /// Derives the correct pet image asset name from the current health value.
        /// Matches the logic in VitalityManager.currentPetAsset.
        var petImageName: String {
            switch health {
            case 0.8...1.0: return "1_pet_happy"
            case 0.4..<0.8: return "2_pet_neutral"
            case 0.1..<0.4: return "3_pet_sad"
            default: return "4_pet_critical"
            }
        }
    }
    
    var petName: String
}
