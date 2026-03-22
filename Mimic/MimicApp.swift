import SwiftUI
import SwiftData

@main
struct MimicApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // 1. Create the container for saving Pet Data
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                PetDashboardView(modelContext: sharedModelContainer.mainContext)
            } else {
                OnboardingContainerView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

