import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vitalityManager: VitalityManager
    @State private var selectedMode: PetMode
    
    init(vitalityManager: VitalityManager) {
        self.vitalityManager = vitalityManager
        _selectedMode = State(initialValue: vitalityManager.currentMode)
    }
    
    var body: some View {
        ZStack {
            Color.theme.backgroundStart
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("Settings")
                        .font(.appFont.largeTitle)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.appFont.headline)
                            .foregroundColor(Color.theme.primary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Pet Mode Selection
                        modeSelectionSection
                        
                        // Current Mode Description
                        modeDescriptionCard
                        
                        // About Section
                        aboutSection
                        
#if DEBUG
                        // Developer Controls
                        developerSection
#endif
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                }
            }
        }
        .onChange(of: selectedMode) { _, newValue in
            vitalityManager.currentMode = newValue
        }
    }
    
    // MARK: - Mode Selection
    private var modeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet Mode")
                .font(.appFont.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            Picker("Mode", selection: $selectedMode) {
                ForEach(PetMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }
    
    // MARK: - Mode Description
    private var modeDescriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(selectedMode.petName)
                    .font(.appFont.title)
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
                
                Image(systemName: iconForMode(selectedMode))
                    .font(.title2)
                    .foregroundColor(Color.theme.secondary)
            }
            
            Text(selectedMode.description)
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }
    
    // MARK: - About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.appFont.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            HStack {
                Text("Version")
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                Text("1.0.0")
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textPrimary)
            }
            
            Divider()
            
            HStack {
                Text("Scars (Total Deaths)")
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                Text("\(vitalityManager.scars)")
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.critical)
            }
            
            Divider()
            
            Button {
                UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                    Text("Replay Onboarding")
                        .font(.appFont.body)
                }
                .foregroundColor(Color.theme.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.theme.secondary.opacity(0.08))
                )
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }
    
#if DEBUG
    // MARK: - Developer Menu
    private var developerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(Color.theme.warning)
                Text("Developer Menu")
                    .font(.appFont.headline)
                    .foregroundColor(Color.theme.warning)
            }
            
            VStack(spacing: 12) {
                Button(action: { vitalityManager.decompose(minutes: 10) }) {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                        Text("Deduct 10% Health")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color.theme.warning)
                
                Button(action: { vitalityManager.decompose(minutes: 50) }) {
                    HStack {
                        Image(systemName: "minus.circle.fill")
                        Text("Deduct 50% Health")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color.theme.critical)
                
                Button(action: { vitalityManager.recover(minutes: 200) }) { // 200 mins = +10%
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add 10% Health")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color.theme.primary)
                
                Button(action: {
                    // Force zero health then trigger check for new day logic validation
                    vitalityManager.decompose(minutes: 100)
                }) {
                    HStack {
                        Image(systemName: "xmark.octagon.fill")
                        Text("Kill Pet (0% Health)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .tint(Color.black)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.theme.warning.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.theme.warning.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
        )
    }
#endif
    
    // MARK: - Helpers
    private func iconForMode(_ mode: PetMode) -> String {
        switch mode {
        case .reflection: return "person.2.fill"
        case .guardian: return "shield.fill"
        case .echo: return "sparkles"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PetEntity.self, configurations: config)
    let vm = VitalityManager(modelContext: container.mainContext)
    
    SettingsView(vitalityManager: vm)
}
