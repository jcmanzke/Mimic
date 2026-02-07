import Foundation
import SwiftData

@Model
final class PetEntity {
    var date: Date
    var currentHealth: Double
    var scars: Int
    var isAlive: Bool
    
    init(date: Date = Date(), currentHealth: Double = 1.0, scars: Int = 0, isAlive: Bool = true) {
        self.date = date
        self.currentHealth = currentHealth
        self.scars = scars
        self.isAlive = isAlive
    }
}
