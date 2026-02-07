import SwiftUI
import SwiftData

struct PetDashboardView: View {
    @State private var vitalityManager: VitalityManager
    @StateObject private var animationVM = PetAnimationViewModel()
    @State private var showingSettings = false
    
    init(modelContext: ModelContext) {
        let vm = VitalityManager(modelContext: modelContext)
        _vitalityManager = State(initialValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Pet Area
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 300)
                    
                    // Rive View Placeholder
                    Text("Pet Animation Here")
                        .font(.title)
                        .foregroundColor(.gray)
                    // RiveViewModel.view() // Uncomment when Rive is installed
                }
                .padding()
                
                // Health Ring
                Gauge(value: vitalityManager.health) {
                    Text("Health")
                } currentValueLabel: {
                    Text("\(Int(vitalityManager.health * 100))%")
                }
                .gaugeStyle(.accessoryCircular)
                .scaleEffect(2.0)
                .padding()
                
                // Controls (For Testing)
                HStack {
                    Button("Distract (-5%)") {
                        vitalityManager.decompose(minutes: 5)
                        animationVM.update(with: vitalityManager.health)
                        // Update Live Activity
                        LiveActivityManager.shared.update(health: vitalityManager.health, state: "Distracted")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Recover (+10m)") {
                        vitalityManager.recover(minutes: 10)
                        animationVM.update(with: vitalityManager.health)
                        // Update Live Activity
                        LiveActivityManager.shared.update(health: vitalityManager.health, state: "Healing")
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("ScreenPet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                ActivitySelectionView()
                    .onDisappear {
                         // Start Live Activity if monitoring starts
                         LiveActivityManager.shared.start()
                    }
            }
            .onAppear {
                animationVM.update(with: vitalityManager.health)
                // Optionally start activity here too
                LiveActivityManager.shared.start()
            }
        }
    }
}
