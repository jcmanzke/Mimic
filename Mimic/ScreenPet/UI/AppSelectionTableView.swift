import SwiftUI

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
                // MARK: - Selected Apps Section
                if !manager.selectedApps.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        sectionLabel("SELECTED APPS", color: Color.theme.primary)
                        
                        ForEach(manager.selectedApps) { app in
                            AppRow(app: app, isSelected: true) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    manager.toggleSelection(for: app.id)
                                }
                            }
                            
                            if app.id != manager.selectedApps.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    
                    // Separator between sections
                    Rectangle()
                        .fill(Color.theme.textSecondary.opacity(0.08))
                        .frame(height: 8)
                }
                
                // MARK: - All Apps Section
                if !manager.unselectedApps.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        sectionLabel("ALL APPS", color: Color.theme.textSecondary)
                        
                        ForEach(manager.unselectedApps) { app in
                            AppRow(app: app, isSelected: false) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    manager.toggleSelection(for: app.id)
                                }
                            }
                            
                            if app.id != manager.unselectedApps.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(24)
        }
    }
    
    // MARK: - Section Label
    
    private func sectionLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.appFont.overline)
            .foregroundColor(color)
            .tracking(0.8)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
    }
}

// MARK: - App Row

struct AppRow: View {
    let app: AppUsageItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(app.iconColor.opacity(0.12))
                    .frame(width: 40, height: 40)
                
                Image(systemName: app.iconSymbol)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(app.iconColor)
            }
            
            // App name
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(app.screenTime)
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
            }
            
            Spacer()
            
            // Select / Selected toggle
            Button(action: onToggle) {
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Selected")
                            .font(.appFont.subheadline)
                    }
                    .foregroundColor(Color.theme.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.theme.primary.opacity(0.1))
                    )
                } else {
                    Text("Select")
                        .font(.appFont.subheadline)
                        .foregroundColor(Color.theme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.theme.textSecondary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
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
