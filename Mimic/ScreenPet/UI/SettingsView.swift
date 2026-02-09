import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vitalityManager: VitalityManager
    @State private var selectedMode: PetMode
    
    init(vitalityManager: VitalityManager) {
        self.vitalityManager = vitalityManager
        _selectedMode = State(initialValue: vitalityManager.currentMode)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.appBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Pet Mode Selection
                        modeSelectionSection
                        
                        // Current Mode Description
                        modeDescriptionCard
                        
                        // Activity Selection
                        activitySection
                        
                        // About Section
                        aboutSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color.theme.textPrimary)
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
        .padding(16)
        .glassCard()
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
        .padding(16)
        .glassCard()
    }
    
    // MARK: - Activity Selection
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Screen Time Monitoring")
                .font(.appFont.headline)
                .foregroundColor(Color.theme.textPrimary)
            
            NavigationLink {
                ActivitySelectionView()
            } label: {
                HStack {
                    Image(systemName: "apps.iphone")
                        .foregroundColor(Color.theme.secondary)
                    
                    Text("Select Apps to Monitor")
                        .font(.appFont.body)
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
    
    // MARK: - About
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            
            HStack {
                Text("Scars (Total Deaths)")
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textSecondary)
                
                Spacer()
                
                Text("\(vitalityManager.scars)")
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.critical)
            }
        }
        .padding(16)
        .glassCard()
    }
    
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
