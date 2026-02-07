import ActivityKit
import Foundation

struct PetActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var health: Double // 0.0 - 1.0
        var petState: String // "Happy", "Sad", etc.
    }
    
    var petName: String
}
