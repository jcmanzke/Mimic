import SwiftUI
import SwiftData

@main
struct MimicApp: App {
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
            // 2. Launch the PetDashboardView instead of ContentView
            PetDashboardView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}

