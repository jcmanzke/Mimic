//
//  TotalActivityReport.swift
//  DeviceActivityReportExtension
//

import DeviceActivity
import ExtensionKit
import SwiftUI

extension DeviceActivityReport.Context {
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    // It returns a tuple of (durationString, pickupCount)
    let content: (String, Int) -> TotalActivityView
    
    nonisolated func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> (String, Int) {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        var totalDuration: TimeInterval = 0
        var totalPickups = 0
        
        for await activityData in data {
            for await segment in activityData.activitySegments {
                totalDuration += segment.totalActivityDuration
                totalPickups += segment.totalPickups
            }
        }
        
        let durationString = formatter.string(from: totalDuration) ?? "0m"
        
        return (durationString, totalPickups)
    }
}
