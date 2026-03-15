import Foundation
import SwiftData
import SwiftUI

@Observable
class VitalityManager {
    var health: Double = 1.0
    var scars: Int = 0
    var guardianStreak: Int = 0
    private var modelContext: ModelContext?
    private var currentPet: PetEntity?
    
    // Pet mode (persisted in UserDefaults)
    var currentMode: PetMode {
        get {
            if let raw = UserDefaults.standard.string(forKey: "petMode"),
               let mode = PetMode(rawValue: raw) {
                return mode
            }
            return .guardian // Default
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "petMode")
        }
    }
    
    /// Current narrative message based on mode and health
    var narrativeMessage: String {
        switch currentMode {
        case .guardian:
            return GuardianNarrative.messageForHealth(health)
        case .reflection, .echo:
            // Placeholder for other modes
            return "Health: \(Int(health * 100))%"
        }
    }
    
    /// Asset name for current health state
    var currentPetAsset: String {
        switch health {
        case 0.8...1.0: return "1_pet_happy"
        case 0.4..<0.8: return "2_pet_neutral"
        case 0.1..<0.4: return "3_pet_sad"
        default: return "4_pet_critical"
        }
    }
    
    // Constants
    private let decayRatePerMinute: Double = 0.01 // 1%
    private let recoveryRatePerTenMinutes: Double = 0.005 // 0.5%
    private let dailyResetHour = 4
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadOrCreateDailyPet()
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadOrCreateDailyPet()
    }
    
    private func loadOrCreateDailyPet() {
        guard let context = modelContext else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        // Adjust for 4 AM reset if needed, but for now simple day check
        // If we want 4 AM to be the "start" of the new day logic, we need to shift checks.
        // Let's stick to simple calendar day for query, but logic handles the 4 AM reset.
        
        let descriptor = FetchDescriptor<PetEntity>(
            predicate: #Predicate { $0.date >= today },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let pets = try context.fetch(descriptor)
            if let existingPet = pets.first {
                self.currentPet = existingPet
                self.health = existingPet.currentHealth
                self.scars = existingPet.scars
                checkDailyReset()
            } else {
                startNewDay()
            }
        } catch {
            print("Failed to fetch pet: \(error)")
        }
    }
    
    private func startNewDay() {
        // Carry over scars from yesterday if needed, or just reset logic?
        // Rules: Daily Reset: At 04:00, health resets to 1.0. If health was 0.0, pet is "Revived" with a "Scar".
        
        // This function is called when NO pet exists for "today" (logic depends on how we define today)
        // Let's actually implement the specific 4 AM check in a separate method or within load.
        
        let newPet = PetEntity(currentHealth: 1.0, scars: self.scars) // Scars persist?
        // Note: logic says "Revived with a Scar (Persistent tally)".
        // So we likely need a separate "UserStats" model or just query the LAST pet to get previous scars.
        
        if let lastPet = fetchLastPet() {
            var newScars = lastPet.scars
            if lastPet.currentHealth <= 0 {
                newScars += 1
            }
            newPet.scars = newScars
            self.scars = newScars
        }
        
        self.health = 1.0
        self.currentPet = newPet
        modelContext?.insert(newPet)
        save()
    }
    
    private func fetchLastPet() -> PetEntity? {
        guard let context = modelContext else { return nil }
        var descriptor = FetchDescriptor<PetEntity>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func checkDailyReset() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        // If it's past 4 AM and the current pet's date is before today 4 AM...
        // This logic is tricky with just "Date". Ideally we store "DayID" or something.
        // For now, relies on startNewDay being called when app launches on a new day.
    }
    
    func decompose(minutes: Double) {
        let decayAmount = minutes * decayRatePerMinute
        health = max(0, health - decayAmount)
        updatePetState()
    }
    
    func recover(minutes: Double) {
        // +0.5% per 10 minutes => 0.005 per 10 mins => 0.0005 per minute
        let recoveryAmount = (minutes / 10.0) * 0.005
        health = min(1.0, health + recoveryAmount)
        updatePetState()
    }
    
    func adjustHealth(by amount: Double) {
        health = max(0, min(1.0, health + amount))
        updatePetState()
    }
    
    private func updatePetState() {
        currentPet?.currentHealth = health
        save()
    }
    
    private func save() {
        try? modelContext?.save()
    }
}
