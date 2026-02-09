import SwiftUI
import SwiftData

struct PetDashboardView: View {
    @State private var vitalityManager: VitalityManager
    @State private var showingSettings = false
    
    init(modelContext: ModelContext) {
        let vm = VitalityManager(modelContext: modelContext)
        _vitalityManager = State(initialValue: vm)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.clear.appBackground()
            
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Pet Display Area
                petDisplaySection
                
                // Narrative Message
                narrativeSection
                
                // Stats Cards
                statsSection
                
                // Testing Controls (Remove in production)
                #if DEBUG
                testingControls
                #endif
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(vitalityManager: vitalityManager)
        }
        .onAppear {
            LiveActivityManager.shared.start()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good \(timeOfDayGreeting)")
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
                
                Text(vitalityManager.currentMode.petName)
                    .font(.appFont.largeTitle)
                    .foregroundColor(Color.theme.textPrimary)
            }
            
            Spacer()
            
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gear")
            }
            .buttonStyle(IconButtonStyle())
        }
        .padding(.top, 16)
    }
    
    // MARK: - Pet Display
    private var petDisplaySection: some View {
        ZStack {
            // Sanctuary background (changes with streak)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.theme.colorForHealth(vitalityManager.health).opacity(0.3),
                            Color.theme.backgroundStart.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .frame(width: 280, height: 280)
            
            // Pet Image
            Image(vitalityManager.currentPetAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .shadow(color: Color.theme.colorForHealth(vitalityManager.health).opacity(0.5), radius: 20)
            
            // Health Ring
            Circle()
                .stroke(Color.theme.cardBorder, lineWidth: 4)
                .frame(width: 240, height: 240)
            
            Circle()
                .trim(from: 0, to: vitalityManager.health)
                .stroke(
                    Color.theme.colorForHealth(vitalityManager.health),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5), value: vitalityManager.health)
        }
    }
    
    // MARK: - Narrative
    private var narrativeSection: some View {
        Text(vitalityManager.narrativeMessage)
            .font(.appFont.headline)
            .foregroundColor(Color.theme.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .animation(.easeInOut, value: vitalityManager.health)
    }
    
    // MARK: - Stats
    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Health",
                value: "\(Int(vitalityManager.health * 100))%",
                subtitle: healthSubtitle,
                accentColor: Color.theme.colorForHealth(vitalityManager.health)
            )
            
            StatCard(
                title: "Guardian Streak",
                value: "\(vitalityManager.guardianStreak)",
                subtitle: "days protected",
                accentColor: Color.theme.secondary
            )
        }
    }
    
    // MARK: - Testing Controls
    #if DEBUG
    private var testingControls: some View {
        VStack(spacing: 12) {
            Text("Testing Controls")
                .font(.appFont.caption)
                .foregroundColor(Color.theme.textSecondary)
            
            HStack(spacing: 12) {
                Button("Distract (-5%)") {
                    vitalityManager.decompose(minutes: 5)
                    LiveActivityManager.shared.update(health: vitalityManager.health, state: "Distracted")
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Recover (+10m)") {
                    vitalityManager.recover(minutes: 10)
                    LiveActivityManager.shared.update(health: vitalityManager.health, state: "Healing")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .glassCard()
    }
    #endif
    
    // MARK: - Helpers
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<21: return "evening"
        default: return "night"
        }
    }
    
    private var healthSubtitle: String {
        switch vitalityManager.health {
        case 0.8...1.0: return "Thriving!"
        case 0.6..<0.8: return "Doing well"
        case 0.4..<0.6: return "Needs care"
        case 0.2..<0.4: return "Struggling"
        default: return "Critical!"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PetEntity.self, configurations: config)
    
    return PetDashboardView(modelContext: container.mainContext)
}
