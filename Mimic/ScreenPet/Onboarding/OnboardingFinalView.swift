import SwiftUI

struct OnboardingFinalView: View {
    let onSetup: () -> Void
    
    @State private var animateIn = false
    @State private var pulseGlow = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Lumi with pulsing glow
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.theme.primary.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: pulseGlow ? 150 : 120
                        )
                    )
                    .frame(width: 280, height: 280)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: pulseGlow
                    )
                
                Image("1_pet_happy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: Color.theme.primary.opacity(0.4), radius: 25)
                    .scaleEffect(animateIn ? 1.0 : 0.8)
                    .opacity(animateIn ? 1 : 0)
            }
            
            Spacer().frame(height: 40)
            
            // Headline
            Text("Lumi is ready\nwhen you are.")
                .font(.custom("PlusJakartaSans-Bold", size: 32))
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
            
            Spacer().frame(height: 12)
            
            // Body
            Text("Set up takes 2 minutes.\nNo app blocking. No judgment. Just awareness.")
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
            
            Spacer()
            
            // Primary CTA
            OnboardingCTAButton("Set up Mimic →") {
                onSetup()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            
            // Secondary link
            Button("Remind me later") {
                onSetup()
            }
            .font(.appFont.body)
            .foregroundColor(Color.theme.textSecondary)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                animateIn = true
            }
            pulseGlow = true
        }
    }
}

#Preview {
    OnboardingFinalView(onSetup: {})
        .appBackground()
}
