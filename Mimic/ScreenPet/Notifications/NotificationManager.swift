//
//  NotificationManager.swift
//  Mimic
//
//  Centralized notification service for ScreenPet / Mimic.
//  Handles all 5 notification types: health thresholds, critical alerts,
//  recovery celebrations, daily summaries, and morning encouragement.
//

import Foundation
import UserNotifications

// MARK: - Notification Type

enum PetNotificationType: String {
    case healthThreshold    // Health crosses 75%, 50%, 25%, 10%
    case criticalAlert      // Health reaches 0%
    case recoveryCelebration // Phone locked for 10+ min
    case dailySummary       // Every evening at 9 PM
    case morningEncouragement // Every morning at 8 AM
}

// MARK: - Notification Category Identifiers

enum PetNotificationCategory: String {
    case healthWarning = "HEALTH_WARNING"
    case criticalHealth = "CRITICAL_HEALTH"
    case recovery = "RECOVERY"
    case dailySummary = "DAILY_SUMMARY"
    case morning = "MORNING"
}

// MARK: - Notification Action Identifiers

enum PetNotificationAction: String {
    case rescue = "RESCUE_ACTION"
    case dismiss = "DISMISS_ACTION"
    case openApp = "OPEN_APP_ACTION"
}

// MARK: - NotificationManager

final class NotificationManager: @unchecked Sendable {
    
    static let shared = NotificationManager()
    
    // MARK: - Constants
    
    private let appGroupID = "group.com.christianmanzke.Mimic"
    
    /// Key for storing which thresholds have already fired today (prevents spam)
    private let firedThresholdsKey = "firedThresholdsToday"
    
    /// Key for storing the last notification timestamp (cooldown)
    private let lastNotificationTimeKey = "lastNotificationTimestamp"
    
    /// Key for storing the date when thresholds were last reset
    private let thresholdResetDateKey = "thresholdResetDate"
    
    /// Minimum seconds between threshold notifications (prevent spam)
    private let cooldownSeconds: TimeInterval = 15 * 60 // 15 minutes
    
    /// Health thresholds that trigger notifications (descending)
    private let healthThresholds: [Double] = [0.75, 0.50, 0.25, 0.10]
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    private init() {}
    
    // MARK: - Permission Management
    
    /// Request notification authorization from the user
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("[NotificationManager] Authorization error: \(error.localizedDescription)")
            }
            completion?(granted)
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }
    
    // MARK: - Category Registration
    
    /// Register notification categories and actions. Call on app launch.
    func registerCategories() {
        // Rescue action — opens the app to a "put phone down" prompt
        let rescueAction = UNNotificationAction(
            identifier: PetNotificationAction.rescue.rawValue,
            title: "Start Rescue 🛡️",
            options: [.foreground]
        )
        
        // Dismiss action — silent acknowledgment
        let dismissAction = UNNotificationAction(
            identifier: PetNotificationAction.dismiss.rawValue,
            title: "I know",
            options: [.destructive]
        )
        
        // Open app action
        let openAppAction = UNNotificationAction(
            identifier: PetNotificationAction.openApp.rawValue,
            title: "Open Mimic",
            options: [.foreground]
        )
        
        // Health Warning category (75%, 50%, 25%)
        let healthWarningCategory = UNNotificationCategory(
            identifier: PetNotificationCategory.healthWarning.rawValue,
            actions: [rescueAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Critical Health category (10% and 0%)
        let criticalHealthCategory = UNNotificationCategory(
            identifier: PetNotificationCategory.criticalHealth.rawValue,
            actions: [rescueAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Recovery category
        let recoveryCategory = UNNotificationCategory(
            identifier: PetNotificationCategory.recovery.rawValue,
            actions: [openAppAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Daily Summary category
        let dailySummaryCategory = UNNotificationCategory(
            identifier: PetNotificationCategory.dailySummary.rawValue,
            actions: [openAppAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Morning category
        let morningCategory = UNNotificationCategory(
            identifier: PetNotificationCategory.morning.rawValue,
            actions: [openAppAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            healthWarningCategory,
            criticalHealthCategory,
            recoveryCategory,
            dailySummaryCategory,
            morningCategory
        ])
        
        print("[NotificationManager] Registered notification categories")
    }
    
    // MARK: - Health Threshold Notifications
    
    /// Check if a health change crosses a threshold and send a notification if needed.
    /// Call this from the DeviceActivityMonitor extension after each health update.
    ///
    /// - Parameters:
    ///   - oldHealth: Health value before the change (0.0–1.0)
    ///   - newHealth: Health value after the change (0.0–1.0)
    func handleHealthChange(oldHealth: Double, newHealth: Double) {
        // Reset fired thresholds at 4 AM daily
        resetThresholdsIfNeeded()
        
        // Check for critical (0%)
        if newHealth <= 0 {
            sendCriticalAlert()
            return
        }
        
        // Check each threshold
        for threshold in healthThresholds {
            if oldHealth > threshold && newHealth <= threshold {
                // Only fire if this threshold hasn't been sent today
                guard !hasThresholdFired(threshold) else {
                    print("[NotificationManager] Threshold \(threshold) already fired today, skipping")
                    continue
                }
                
                // Check cooldown
                guard isCooldownExpired() else {
                    print("[NotificationManager] Cooldown active, skipping threshold \(threshold)")
                    continue
                }
                
                sendHealthThresholdNotification(threshold: threshold, health: newHealth)
                markThresholdFired(threshold)
                updateLastNotificationTime()
                break // Only fire one threshold per health change
            }
        }
    }
    
    /// Send a health threshold notification
    private func sendHealthThresholdNotification(threshold: Double, health: Double) {
        let content = UNMutableNotificationContent()
        content.title = GuardianNarrative.notificationTitle(for: .healthThreshold)
        content.body = GuardianNarrative.notificationBody(for: .healthThreshold, health: threshold)
        content.sound = .default
        content.categoryIdentifier = threshold <= 0.10
            ? PetNotificationCategory.criticalHealth.rawValue
            : PetNotificationCategory.healthWarning.rawValue
        
        // Store health in userInfo for the app to read on notification tap
        content.userInfo = [
            "type": PetNotificationType.healthThreshold.rawValue,
            "health": health,
            "threshold": threshold
        ]
        
        let request = UNNotificationRequest(
            identifier: "health_threshold_\(Int(threshold * 100))",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to send threshold notification: \(error)")
            } else {
                print("[NotificationManager] Sent threshold notification for \(Int(threshold * 100))%")
            }
        }
    }
    
    /// Send a critical alert when health reaches 0%
    private func sendCriticalAlert() {
        guard !hasThresholdFired(0.0) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = GuardianNarrative.notificationTitle(for: .criticalAlert)
        content.body = GuardianNarrative.notificationBody(for: .criticalAlert, health: 0)
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = PetNotificationCategory.criticalHealth.rawValue
        content.userInfo = [
            "type": PetNotificationType.criticalAlert.rawValue,
            "health": 0.0
        ]
        
        let request = UNNotificationRequest(
            identifier: "critical_alert",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to send critical alert: \(error)")
            } else {
                print("[NotificationManager] Sent critical alert")
            }
        }
        
        markThresholdFired(0.0)
        updateLastNotificationTime()
    }
    
    // MARK: - Recovery Celebration
    
    /// Send a recovery celebration notification when the user puts their phone down.
    ///
    /// - Parameter minutes: How many minutes the phone was locked
    func sendRecoveryCelebration(minutes: Double) {
        let content = UNMutableNotificationContent()
        content.title = GuardianNarrative.notificationTitle(for: .recoveryCelebration)
        content.body = GuardianNarrative.notificationBody(for: .recoveryCelebration, health: minutes / 60.0)
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = PetNotificationCategory.recovery.rawValue
        content.userInfo = [
            "type": PetNotificationType.recoveryCelebration.rawValue,
            "recoveryMinutes": minutes
        ]
        
        let request = UNNotificationRequest(
            identifier: "recovery_celebration",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to send recovery notification: \(error)")
            }
        }
    }
    
    // MARK: - Scheduled Notifications
    
    /// Schedule the recurring daily summary notification (9 PM every day).
    func scheduleDailySummary() {
        // Remove existing daily summary to avoid duplicates
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily_summary"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = GuardianNarrative.notificationTitle(for: .dailySummary)
        content.body = GuardianNarrative.notificationBody(for: .dailySummary, health: -1) // Health will be read from shared defaults at delivery
        content.sound = .default
        content.categoryIdentifier = PetNotificationCategory.dailySummary.rawValue
        content.userInfo = ["type": PetNotificationType.dailySummary.rawValue]
        
        // Trigger at 9 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_summary",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to schedule daily summary: \(error)")
            } else {
                print("[NotificationManager] Scheduled daily summary at 9 PM")
            }
        }
    }
    
    /// Schedule the recurring morning encouragement notification (8 AM every day).
    func scheduleMorningEncouragement() {
        // Remove existing morning notification to avoid duplicates
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["morning_encouragement"]
        )
        
        let content = UNMutableNotificationContent()
        content.title = GuardianNarrative.notificationTitle(for: .morningEncouragement)
        content.body = GuardianNarrative.notificationBody(for: .morningEncouragement, health: 1.0)
        content.sound = .default
        content.categoryIdentifier = PetNotificationCategory.morning.rawValue
        content.userInfo = ["type": PetNotificationType.morningEncouragement.rawValue]
        
        // Trigger at 8 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "morning_encouragement",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to schedule morning encouragement: \(error)")
            } else {
                print("[NotificationManager] Scheduled morning encouragement at 8 AM")
            }
        }
    }
    
    /// Schedule all recurring notifications. Call after onboarding or on app launch.
    func scheduleRecurringNotifications() {
        scheduleDailySummary()
        scheduleMorningEncouragement()
    }
    
    /// Cancel all scheduled recurring notifications (e.g., if user disables them in Settings).
    func cancelAllRecurringNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily_summary", "morning_encouragement"]
        )
        print("[NotificationManager] Cancelled all recurring notifications")
    }
    
    // MARK: - Cooldown & Deduplication
    
    /// Check if the cooldown period has expired since the last threshold notification
    private func isCooldownExpired() -> Bool {
        guard let defaults = sharedDefaults,
              let lastTime = defaults.object(forKey: lastNotificationTimeKey) as? Date else {
            return true // No previous notification, cooldown is "expired"
        }
        return Date().timeIntervalSince(lastTime) >= cooldownSeconds
    }
    
    /// Update the timestamp of the last sent notification
    private func updateLastNotificationTime() {
        sharedDefaults?.set(Date(), forKey: lastNotificationTimeKey)
    }
    
    /// Check if a specific threshold has already fired today
    private func hasThresholdFired(_ threshold: Double) -> Bool {
        guard let defaults = sharedDefaults,
              let fired = defaults.array(forKey: firedThresholdsKey) as? [Double] else {
            return false
        }
        return fired.contains(threshold)
    }
    
    /// Mark a threshold as fired for today
    private func markThresholdFired(_ threshold: Double) {
        let defaults = sharedDefaults
        var fired = (defaults?.array(forKey: firedThresholdsKey) as? [Double]) ?? []
        fired.append(threshold)
        defaults?.set(fired, forKey: firedThresholdsKey)
    }
    
    /// Reset fired thresholds at the start of each new "pet day" (4 AM)
    private func resetThresholdsIfNeeded() {
        let defaults = sharedDefaults
        let now = Date()
        let calendar = Calendar.current
        
        // Calculate today's 4 AM
        var todayAt4AM = calendar.startOfDay(for: now)
        todayAt4AM = calendar.date(byAdding: .hour, value: 4, to: todayAt4AM) ?? todayAt4AM
        
        // If it's before 4 AM, use yesterday's 4 AM as the reset point
        if now < todayAt4AM {
            todayAt4AM = calendar.date(byAdding: .day, value: -1, to: todayAt4AM) ?? todayAt4AM
        }
        
        if let lastReset = defaults?.object(forKey: thresholdResetDateKey) as? Date {
            if lastReset < todayAt4AM {
                // New pet day has started, reset thresholds
                defaults?.removeObject(forKey: firedThresholdsKey)
                defaults?.set(now, forKey: thresholdResetDateKey)
                print("[NotificationManager] Reset thresholds for new pet day")
            }
        } else {
            // First time — set the reset date
            defaults?.set(now, forKey: thresholdResetDateKey)
        }
    }
    
    // MARK: - Debug / Testing
    
    #if DEBUG
    /// Send a test notification immediately (for debug controls)
    func sendTestNotification(type: PetNotificationType, health: Double = 0.5) {
        let content = UNMutableNotificationContent()
        content.title = GuardianNarrative.notificationTitle(for: type)
        content.body = GuardianNarrative.notificationBody(for: type, health: health)
        content.sound = .default
        content.userInfo = ["type": type.rawValue, "health": health]
        
        let request = UNNotificationRequest(
            identifier: "test_\(type.rawValue)_\(UUID().uuidString.prefix(8))",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Test notification failed: \(error)")
            } else {
                print("[NotificationManager] Test notification sent: \(type.rawValue)")
            }
        }
    }
    #endif
}
