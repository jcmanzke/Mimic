import SwiftUI
import FamilyControls
import DeviceActivity
import Combine

class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    
    @Published var activitySelection = FamilyActivitySelection()
    
    private let center = AuthorizationCenter.shared
    
    func requestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                print("Authorization successful")
            } catch {
                print("Authorization failed: \(error)")
            }
        }
    }
    
    func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let event = DeviceActivityEvent(
            applications: activitySelection.applicationTokens,
            categories: activitySelection.categoryTokens,
            webDomains: activitySelection.webDomainTokens,
            threshold: DateComponents(minute: 5) // Trigger every 5 minutes?
        )
        
        // Note: 'threshold' in DeviceActivityEvent is for "Time Limit" type monitoring.
        // For "Usage Tracking" to deduct health periodically, we might need a different approach
        // or rely on the `intervalDidEnd` or `eventDidReachThreshold`.
        // If we want to deduct 1% per minute, we ideally want callbacks every minute.
        // However, DeviceActivityMonitor doesn't give minute-by-minute callbacks easily for simple usage.
        // Strategy: Set a threshold for 1 minute? Then 2? This is hard.
        // Alternative: The Monitor Extension checks context when the device is used.
        
        // For this MVP: 
        // We will set a threshold of 5 minutes. When it triggers, we deduct.
        // Then we might need to reschedule or use multiple thresholds?
        // Actually, Apple's API isn't great for "continuous polling".
        // Better approach for Game Health:
        // Use `intervalDidStart` and check historical usage? No, that's not real time.
        
        // Accepted simplified approach:
        // Monitor specific categories.
        // Use `.threshold(DateComponents(minute: 5))` to trigger a specific event.
        
        let center = DeviceActivityCenter()
        do {
            try center.startMonitoring(
                DeviceActivityName("ScreenPetMonitor"),
                during: schedule,
                events: [
                    DeviceActivityEvent.Name("HealthDecay"): event
                ]
            )
            print("Monitoring started")
        } catch {
            print("Monitoring failed: \(error)")
        }
    }
}
