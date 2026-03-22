import SwiftUI
import SwiftData

struct PetDashboardView: View {
    @State private var vitalityManager: VitalityManager
    @State private var showingSettings = false
    @State private var wobbleAmount: Double = 0 // Track the current tilt
    @State private var appUsageManager = AppUsageManager()
    
    init(modelContext: ModelContext) {
        let vm = VitalityManager(modelContext: modelContext)
        _vitalityManager = State(initialValue: vm)
    }
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Pet Display Area
                    petDisplaySection
                    
                    // Impact & Vitality Stats
                    impactSection
                    
                    // App Selection Table
                    AppSelectionTableView(manager: appUsageManager)
                    
                    // Testing Controls (Remove in production)
                    #if DEBUG
                    testingControls
                    replayOnboardingButton
                    #endif
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .appBackground()
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
                // 1. Apply the rotation based on our state variable
                .rotationEffect(.degrees(wobbleAmount))
                // 2. Add an action on tap
                .onTapGesture {
                    // Trigger haptic feedback (optional but feels good)
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    // Trigger the animation
                    withAnimation(
                        .spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0)
                    ) {
                        wobbleAmount = 15 // Tilt right
                    }
                    
                    // Reset back to center shortly after
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(
                            .spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0)
                        ) {
                            wobbleAmount = -10 // Tilt slightly left
                        }
                    }
                    
                    // Settle back to 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                            wobbleAmount = 0
                        }
                    }
                }
            
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
    
    // MARK: - Impact & Stats Sections
    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CURRENT IMPACT")
                .font(.appFont.overline)
                .foregroundColor(Color.theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
                .padding(.horizontal, 8)
            
            HStack(spacing: 16) {
                ImpactStatCard(
                    iconName: "chart.bar.xaxis",
                    iconColor: Color.theme.primary,
                    value: "6h 12m",
                    subtitle: "Screen Time"
                )
                
                ImpactStatCard(
                    iconName: "bell.badge",
                    iconColor: Color(hex: "9F7446"), // Bronze warning color
                    value: "142",
                    subtitle: "Pickups Today"
                )
            }
            
            VitalityScoreCard(
                health: vitalityManager.health,
                message: vitalityManager.narrativeMessage
            )
        }
    }
    
    // MARK: - Testing Controls
    #if DEBUG
    private var testingControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("TESTING CONTROLS")
                .font(.appFont.overline)
                .foregroundColor(Color.theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
            
            HStack(spacing: 12) {
                Button("-20% Health") {
                    vitalityManager.adjustHealth(by: -0.2)
                    LiveActivityManager.shared.update(health: vitalityManager.health, state: "Distracted")
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("+20% Health") {
                    vitalityManager.adjustHealth(by: 0.2)
                    LiveActivityManager.shared.update(health: vitalityManager.health, state: "Healing")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
    }
    
    private var replayOnboardingButton: some View {
        Button {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.appFont.subheadline)
                Text("Replay Onboarding")
                    .font(.appFont.caption)
            }
            .foregroundColor(Color.theme.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.theme.textSecondary.opacity(0.08))
            )
        }
        .frame(maxWidth: .infinity)
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

// MARK: - Extra Components
struct ImpactStatCard: View {
    let iconName: String
    let iconColor: Color
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.appFont.title)
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(subtitle)
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
    }
}

struct VitalityScoreCard: View {
    let health: Double
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VITALITY SCORE")
                .font(.appFont.overline)
                .foregroundColor(Color.theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.8)
            
            HStack {
                Text("\(Int(health * 100))%")
                    .font(.appFont.display)
                    .foregroundColor(Color.theme.primary)
                
                Spacer()
                
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color.theme.primary)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.theme.textSecondary.opacity(0.15))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.theme.primary)
                        .frame(width: max(0, min(geometry.size.width * CGFloat(health), geometry.size.width)), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.top, 4)
            .padding(.bottom, 8)
            
            Text(message)
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
    }
}
