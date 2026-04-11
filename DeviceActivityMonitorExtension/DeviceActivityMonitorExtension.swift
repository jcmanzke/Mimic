//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Created for ScreenPet / Mimic.
//  IMPORTANT: This file belongs in the "DeviceActivityMonitor Extension" target.
//
//  This extension runs in a separate sandboxed process. It communicates with the
//  main app via App Group shared UserDefaults and SwiftData.
//

import DeviceActivity
import ManagedSettings
import Foundation
import SwiftData
import UserNotifications

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    private let appGroupID = "group.com.christianmanzke.Mimic"
    
    // MARK: - Lifecycle
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("[Extension] Interval did start for: \(activity.rawValue)")
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("[Extension] Interval did end for: \(activity.rawValue)")
    }
    
    // MARK: - Threshold Events
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // All our health decay events start with "HealthDecay_"
        guard event.rawValue.hasPrefix("HealthDecay") else { return }
        
        print("[Extension] Threshold reached: \(event.rawValue)")
        
        // 1. Set up shared SwiftData container via App Group
        let schema = Schema([PetEntity.self])
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            print("[Extension] App Group container not available")
            return
        }
        
        let storeURL = containerURL.appendingPathComponent("Mimic.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        
        guard let container = try? ModelContainer(for: schema, configurations: [modelConfiguration]) else {
            print("[Extension] Failed to create ModelContainer")
            return
        }
        
        // 2. Load VitalityManager with shared context and deduct health
        let context = ModelContext(container)
        let vm = VitalityManager(modelContext: context)
        
        let oldHealth = vm.health
        vm.decompose(minutes: 5) // Each threshold = 5 minutes of distracting app usage
        let newHealth = vm.health
        
        print("[Extension] Health: \(Int(oldHealth * 100))% → \(Int(newHealth * 100))%")
        
        // 3. Store current health in shared UserDefaults for notifications/widgets
        let defaults = UserDefaults(suiteName: appGroupID)
        defaults?.set(newHealth, forKey: "currentHealth")
        defaults?.set(Date().timeIntervalSince1970, forKey: "lastHealthUpdate")
        
        // 4. Send notification if a threshold was crossed
        NotificationManager.shared.handleHealthChange(oldHealth: oldHealth, newHealth: newHealth)
    }
    
    // MARK: - Warning Callbacks
    
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}
