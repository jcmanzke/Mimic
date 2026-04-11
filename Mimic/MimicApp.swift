import SwiftUI
import SwiftData
import UserNotifications

@main
struct MimicApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 1. Create the container for saving Pet Data
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PetEntity.self,
        ])
        
        let modelConfiguration: ModelConfiguration
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.christianmanzke.Mimic") {
            let storeURL = containerURL.appendingPathComponent("Mimic.sqlite")
            modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

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
                    // Request notification permission & schedule recurring notifications
                    NotificationManager.shared.requestAuthorization { granted in
                        if granted {
                            NotificationManager.shared.scheduleRecurringNotifications()
                        }
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - AppDelegate for Notification Handling

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Register notification categories on every app launch
        NotificationManager.shared.registerCategories()
        
        // Set ourselves as the notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Re-schedule recurring notifications if user has completed onboarding
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            NotificationManager.shared.scheduleRecurringNotifications()
        }
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Called when a notification is delivered while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show banner + sound even when app is in foreground (useful for recovery celebrations)
        completionHandler([.banner, .sound])
    }
    
    /// Called when the user taps on a notification or selects an action
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        switch actionIdentifier {
        case PetNotificationAction.rescue.rawValue:
            // User tapped "Start Rescue 🛡️" — navigate to rescue mission screen
            // TODO: Post a notification to navigate to rescue mission UI
            print("[AppDelegate] User started rescue mission")
            NotificationCenter.default.post(name: .startRescueMission, object: nil)
            
        case PetNotificationAction.dismiss.rawValue:
            // User tapped "I know" — just acknowledge, no guilt
            print("[AppDelegate] User dismissed health warning")
            
        case PetNotificationAction.openApp.rawValue:
            // User tapped "Open Mimic" — just open the app (default behavior)
            print("[AppDelegate] User opened app from notification")
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification body itself
            if let type = userInfo["type"] as? String {
                print("[AppDelegate] User tapped notification of type: \(type)")
            }
            
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Custom Notification Names

extension Notification.Name {
    /// Posted when the user taps "Start Rescue" on a notification action
    static let startRescueMission = Notification.Name("startRescueMission")
}
