//
//  DeviceActivityReportExtension.swift
//  DeviceActivityReportExtension
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct MimicDeviceActivityReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { durationText, pickups in
            TotalActivityView(totalDurationString: durationText, totalPickups: pickups)
        }
        // Add more reports here...
    }
}
