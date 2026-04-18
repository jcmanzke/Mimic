//
//  DeviceActivityReportExtension.swift
//  DeviceActivityReportExtension
//

@preconcurrency import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct MimicDeviceActivityReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { configuration in
            TotalActivityView(totalDurationString: configuration.durationString, totalPickups: configuration.pickups)
        }
        // Add more reports here...
    }
}
