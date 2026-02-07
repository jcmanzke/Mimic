import SwiftUI
import FamilyControls

struct ActivitySelectionView: View {
    @StateObject private var manager = DeviceActivityManager.shared
    @State private var isPresented = false
    
    var body: some View {
        VStack {
            Button("Select Distracting Apps") {
                isPresented = true
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Button("Start Monitoring") {
                manager.startMonitoring()
            }
            .padding()
        }
        .onAppear {
            manager.requestAuthorization()
        }
        .familyActivityPicker(isPresented: $isPresented, selection: $manager.activitySelection)
    }
}
