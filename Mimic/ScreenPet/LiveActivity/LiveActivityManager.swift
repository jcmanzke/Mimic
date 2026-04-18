import ActivityKit
import Foundation

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<PetActivityAttributes>?
    
    /// Shared App Group UserDefaults key for health state
    private let healthKey = "liveActivityHealth"
    private let stateKey = "liveActivityPetState"
    
    func start() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] Activities not enabled on this device")
            return
        }
        
        // Check if there's already an active Live Activity we can reuse
        if let existing = Activity<PetActivityAttributes>.activities.first {
            currentActivity = existing
            print("[LiveActivity] Reusing existing activity: \(existing.id)")
            return
        }
        
        let attributes = PetActivityAttributes(petName: "Lumi")
        
        // Restore last known health from App Group, or default to 100%
        let defaults = UserDefaults(suiteName: "group.com.christianmanzke.Mimic") ?? UserDefaults.standard
        let savedHealth = defaults.double(forKey: healthKey)
        let savedState = defaults.string(forKey: stateKey) ?? "Happy"
        let health = savedHealth > 0 ? savedHealth : 1.0
        
        let initialState = PetActivityAttributes.ContentState(health: health, petState: savedState)
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("[LiveActivity] Started: \(currentActivity?.id ?? "")")
        } catch {
            print("[LiveActivity] Error starting: \(error)")
        }
    }
    
    func update(health: Double, state: String) {
        // Persist to App Group so the widget extension & next launch can read it
        let defaults = UserDefaults(suiteName: "group.com.christianmanzke.Mimic") ?? UserDefaults.standard
        defaults.set(health, forKey: healthKey)
        defaults.set(state, forKey: stateKey)
        
        // If we lost track of the activity, try to find it
        if currentActivity == nil {
            currentActivity = Activity<PetActivityAttributes>.activities.first
        }
        
        guard let activity = currentActivity else {
            print("[LiveActivity] No active activity to update")
            return
        }
        
        let newState = PetActivityAttributes.ContentState(health: health, petState: state)
        let content = ActivityContent(state: newState, staleDate: nil)
        
        Task {
            await activity.update(content)
        }
    }
    
    func stop() {
        Task {
            await currentActivity?.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
