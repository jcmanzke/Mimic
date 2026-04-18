import SwiftUI
import FamilyControls

struct AppSelectionTableView: View {
    @Bindable var manager: AppUsageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("YOUR APPS")
                .font(.appFont.overline)
                .foregroundColor(Color.theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 8)
            
            VStack(spacing: 0) {
                // Selection summary
                if manager.hasSelection {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color.theme.primary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tracking \(manager.selectionCount) item\(manager.selectionCount == 1 ? "" : "s")")
                                    .font(.appFont.headline)
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text("Tap below to change your selection")
                                    .font(.appFont.caption)
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        
                        Divider()
                            .padding(.horizontal, 20)
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "apps.iphone")
                            .font(.system(size: 32))
                            .foregroundColor(Color.theme.textSecondary.opacity(0.4))
                        
                        Text("No apps selected yet")
                            .font(.appFont.body)
                            .foregroundColor(Color.theme.textSecondary)
                        
                        Text("Choose which apps to monitor")
                            .font(.appFont.caption)
                            .foregroundColor(Color.theme.textSecondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                
                // Select Apps Button
                Button {
                    manager.isPickerPresented = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: manager.hasSelection ? "pencil.circle.fill" : "plus.circle.fill")
                            .font(.system(size: 16))
                        
                        Text(manager.hasSelection ? "Change Apps" : "Select Apps")
                            .font(.appFont.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.theme.primary)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color.white)
            .cornerRadius(24)
        }
        .familyActivityPicker(
            isPresented: $manager.isPickerPresented,
            selection: $manager.activitySelection
        )
        .onChange(of: manager.activitySelection) { _, _ in
            manager.saveSelection()
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        AppSelectionTableView(manager: AppUsageManager())
            .padding(.horizontal, 24)
    }
    .appBackground()
}
