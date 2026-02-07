import SwiftUI
import Combine
// import RiveRuntime // Uncomment when RiveRuntime is installed

class PetAnimationViewModel: ObservableObject {
    @Published var healthLevel: Double = 1.0
    
    // Rive Inputs
    // let riveViewModel = RiveViewModel(fileName: "screenpet", stateMachineName: "State Machine 1")
    
    func update(with health: Double) {
        self.healthLevel = health
        updateRiveState()
    }
    
    private func updateRiveState() {
        // Map health to inputs
        // riveViewModel.setInput("healthValue", value: healthLevel * 100)
        
        /*
        States mapping logic:
        100 - 80: Trigger "Happy/Idle"
        79 - 40: Trigger "Neutral/Bored"
        39 - 10: Trigger "Sad/Tired"
        < 10: Trigger "Fainting"
        
        This logic is handled by the State Machine in Rive based on the numeric input "healthValue".
        */
    }
}
