import Foundation
import SwiftUI
import FamilyControls

// MARK: - App Usage Manager

@Observable
class AppUsageManager {
    var activitySelection = FamilyActivitySelection()
    var isPickerPresented = false
    
    private let selectionKey = "savedFamilyActivitySelection"
    
    /// Whether the user has selected any apps/categories to track
    var hasSelection: Bool {
        !activitySelection.applicationTokens.isEmpty ||
        !activitySelection.categoryTokens.isEmpty ||
        !activitySelection.webDomainTokens.isEmpty
    }
    
    /// Total number of selected items (apps + categories + domains)
    var selectionCount: Int {
        activitySelection.applicationTokens.count +
        activitySelection.categoryTokens.count +
        activitySelection.webDomainTokens.count
    }
    
    init() {
        restoreSelection()
    }
    
    /// Save the user's selection after they pick apps
    func saveSelection() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(activitySelection) {
            UserDefaults.standard.set(data, forKey: selectionKey)
        }
    }
    
    /// Restore selection from UserDefaults
    private func restoreSelection() {
        guard let data = UserDefaults.standard.data(forKey: selectionKey) else { return }
        let decoder = JSONDecoder()
        if let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) {
            activitySelection = selection
        }
    }
}
