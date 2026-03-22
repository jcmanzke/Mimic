import SwiftUI

struct OnboardingProcessingView: View {
    let onComplete: () -> Void
    
    @State private var step1Progress: Double = 0
    @State private var step2Progress: Double = 0
    @State private var step3Progress: Double = 0
    @State private var currentStep = 0
    @State private var completed = false
    
    private let steps = [
        "Understanding your patterns...",
        "Matching you with Lumi...",
        "Building your wellbeing plan..."
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Lumi with gentle breathing animation
            Image("1_pet_happy")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .shadow(color: Color.theme.primary.opacity(0.2), radius: 15)
                .scaleEffect(completed ? 1.0 : 0.95)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: completed
                )
            
            Spacer().frame(height: 48)
            
            // Progress steps
            VStack(alignment: .leading, spacing: 20) {
                progressRow(label: steps[0], progress: step1Progress, isActive: currentStep >= 0)
                progressRow(label: steps[1], progress: step2Progress, isActive: currentStep >= 1)
                progressRow(label: steps[2], progress: step3Progress, isActive: currentStep >= 2)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func progressRow(label: String, progress: Double, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.appFont.body)
                .foregroundColor(isActive ? Color.theme.textPrimary : Color.theme.textSecondary.opacity(0.4))
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.theme.textSecondary.opacity(0.12))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(Color.theme.primary)
                        .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .opacity(isActive ? 1 : 0.4)
    }
    
    private func startAnimation() {
        // Step 1: 0-1.0s
        withAnimation(.easeInOut(duration: 1.0)) {
            step1Progress = 1.0
            currentStep = 0
        }
        
        // Step 2: 1.2-2.2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            currentStep = 1
            withAnimation(.easeInOut(duration: 1.0)) {
                step2Progress = 1.0
            }
        }
        
        // Step 3: 2.4-3.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            currentStep = 2
            withAnimation(.easeInOut(duration: 1.0)) {
                step3Progress = 1.0
            }
        }
        
        // Complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            completed = true
            onComplete()
        }
    }
}

#Preview {
    OnboardingProcessingView(onComplete: {})
        .appBackground()
}
