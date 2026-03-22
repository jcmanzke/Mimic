import Foundation
import SwiftUI

// MARK: - App Usage Item Model

struct AppUsageItem: Identifiable, Equatable {
    let id: String          // Unique identifier (bundle-id style)
    let name: String        // Display name
    let iconSymbol: String  // SF Symbol name
    let iconColor: Color    // Tint color for the icon
    let screenTime: String  // Formatted screen time string
    var isSelected: Bool    // Whether user marked this as "bad"
}

// MARK: - App Usage Manager

@Observable
class AppUsageManager {
    var apps: [AppUsageItem] = []
    
    /// Apps the user marked as "bad" (distracting)
    var selectedApps: [AppUsageItem] {
        apps.filter { $0.isSelected }
    }
    
    /// Apps not yet selected
    var unselectedApps: [AppUsageItem] {
        apps.filter { !$0.isSelected }
    }
    
    private let selectedAppsKey = "selectedBadAppIDs"
    
    init() {
        loadMockData()
        restoreSelections()
    }
    
    /// Toggle selection state for an app
    func toggleSelection(for appID: String) {
        guard let index = apps.firstIndex(where: { $0.id == appID }) else { return }
        apps[index].isSelected.toggle()
        persistSelections()
    }
    
    // MARK: - Persistence
    
    private func persistSelections() {
        let selectedIDs = apps.filter { $0.isSelected }.map { $0.id }
        UserDefaults.standard.set(selectedIDs, forKey: selectedAppsKey)
    }
    
    private func restoreSelections() {
        guard let savedIDs = UserDefaults.standard.stringArray(forKey: selectedAppsKey) else { return }
        for i in apps.indices {
            apps[i].isSelected = savedIDs.contains(apps[i].id)
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        apps = [
            AppUsageItem(
                id: "com.instagram.app",
                name: "Instagram",
                iconSymbol: "camera.fill",
                iconColor: Color(hex: "E1306C"),
                screenTime: "2h 14m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.tiktok.app",
                name: "TikTok",
                iconSymbol: "music.note",
                iconColor: Color(hex: "010101"),
                screenTime: "1h 47m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.google.youtube",
                name: "YouTube",
                iconSymbol: "play.rectangle.fill",
                iconColor: Color(hex: "FF0000"),
                screenTime: "58m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.apple.safari",
                name: "Safari",
                iconSymbol: "safari.fill",
                iconColor: Color(hex: "006CFF"),
                screenTime: "42m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.twitter.app",
                name: "X (Twitter)",
                iconSymbol: "bubble.left.fill",
                iconColor: Color(hex: "1DA1F2"),
                screenTime: "36m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.apple.messages",
                name: "Messages",
                iconSymbol: "message.fill",
                iconColor: Color(hex: "34C759"),
                screenTime: "28m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.snapchat.app",
                name: "Snapchat",
                iconSymbol: "bolt.fill",
                iconColor: Color(hex: "FFFC00"),
                screenTime: "22m",
                isSelected: false
            ),
            AppUsageItem(
                id: "com.netflix.app",
                name: "Netflix",
                iconSymbol: "tv.fill",
                iconColor: Color(hex: "E50914"),
                screenTime: "15m",
                isSelected: false
            ),
        ]
    }
}
