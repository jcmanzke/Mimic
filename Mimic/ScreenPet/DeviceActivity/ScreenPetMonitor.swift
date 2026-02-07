//
//  ScreenPetMonitor.swift
//  DeviceActivityMonitorExtension
//
//  Created for ScreenPet.
//  IMPORTANT: This file belongs in the "DeviceActivityMonitor Extension" target.
//

import DeviceActivity
import ManagedSettings
import Foundation
import Combine

// Note: You need to make sure VitalityManager is accessible here (e.g. via specific file membership or shared framework)
// OR interact with Shared Defaults / SwiftData. 
// Since we used SwiftData, the ModelContainer needs to be set up here too.

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    nonisolated override init() {
        super.init()
    }
    
    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("Interval did start")
    }
    
    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("Interval did end")
        // Maybe calculate total usage here?
    }
    
    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle health deduction
        if event.rawValue == "HealthDecay" {
            // Deduct health
            // This runs in a verified extension sandbox.
            // We need to write to the shared data.
            
            // For now, let's print. Real implementation requires shared container setup.
            print("Threshold reached! Deducting health...")
            
            // TODO: Initialize VitalityManager with shared ModelContainer
            // let context = ...
            // let vm = VitalityManager(modelContext: context)
            // vm.decompose(minutes: 5)
        }
    }
    
    nonisolated override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
    }
    
    nonisolated override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }
    
    nonisolated override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventWillReachThresholdWarning(event, activity: activity)
    }
}
