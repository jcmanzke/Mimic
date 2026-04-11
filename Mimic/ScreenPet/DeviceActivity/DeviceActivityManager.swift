import SwiftUI
import FamilyControls
import DeviceActivity
import Combine

class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    
    @Published var activitySelection = FamilyActivitySelection()
    
    private let center = AuthorizationCenter.shared
    
    /// Maximum minutes to track per day (24 thresholds × 5 min = 120 min)
    private let maxTrackedMinutes = 120
    
    /// Interval between thresholds in minutes
    private let thresholdIntervalMinutes = 5
    
    func requestAuthorization() {
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                print("[DeviceActivityManager] Authorization successful")
            } catch {
                print("[DeviceActivityManager] Authorization failed: \(error)")
            }
        }
    }
    
    /// Start monitoring with multiple thresholds for continuous health decay.
    ///
    /// Apple's DeviceActivityEvent fires ONCE when usage reaches a threshold.
    /// To get periodic callbacks, we register multiple events:
    /// - HealthDecay_5   → fires at 5 min cumulative usage
    /// - HealthDecay_10  → fires at 10 min
    /// - HealthDecay_15  → fires at 15 min
    /// - ... up to HealthDecay_120 (2 hours)
    ///
    /// Each event triggers `eventDidReachThreshold` in the extension,
    /// which deducts 5 minutes of health decay.
    func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        // Build events dictionary with thresholds every 5 minutes
        var events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        
        for minutes in stride(from: thresholdIntervalMinutes, through: maxTrackedMinutes, by: thresholdIntervalMinutes) {
            let eventName = DeviceActivityEvent.Name("HealthDecay_\(minutes)")
            let event = DeviceActivityEvent(
                applications: activitySelection.applicationTokens,
                categories: activitySelection.categoryTokens,
                webDomains: activitySelection.webDomainTokens,
                threshold: DateComponents(minute: minutes)
            )
            events[eventName] = event
        }
        
        let activityCenter = DeviceActivityCenter()
        do {
            try activityCenter.startMonitoring(
                DeviceActivityName("ScreenPetMonitor"),
                during: schedule,
                events: events
            )
            print("[DeviceActivityManager] Monitoring started with \(events.count) thresholds (every \(thresholdIntervalMinutes) min, up to \(maxTrackedMinutes) min)")
        } catch {
            print("[DeviceActivityManager] Monitoring failed: \(error)")
        }
    }
    
    /// Stop all monitoring
    func stopMonitoring() {
        let activityCenter = DeviceActivityCenter()
        activityCenter.stopMonitoring([DeviceActivityName("ScreenPetMonitor")])
        print("[DeviceActivityManager] Monitoring stopped")
    }
}
