import ActivityKit
import Foundation

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<PetActivityAttributes>?
    
    func start() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = PetActivityAttributes(petName: "ScreenPet")
        let initialState = PetActivityAttributes.ContentState(health: 1.0, petState: "Happy")
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil // or .token if push updates needed
            )
            print("Live Activity Started: \(currentActivity?.id ?? "")")
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    func update(health: Double, state: String) {
        guard let activity = currentActivity else { return }
        
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
