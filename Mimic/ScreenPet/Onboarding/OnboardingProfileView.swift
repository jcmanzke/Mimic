import SwiftUI

struct OnboardingProfileView: View {
    let profile: EmpathyProfile
    let screenTimeHours: Double
    let onContinue: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            // Subheader
            Text("Your relationship style is")
                .font(.appFont.caption)
                .foregroundColor(Color.theme.textSecondary)
                .textCase(.uppercase)
                .tracking(1.5)
                .opacity(animateIn ? 1 : 0)
            
            Spacer().frame(height: 8)
            
            // Profile title
            Text(profile.title)
                .font(.custom("PlusJakartaSans-Bold", size: 32))
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 15)
            
            Spacer().frame(height: 24)
            
            // Pet visual (matching state based on screen time)
            Image(profilePetAsset)
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .shadow(color: Color.theme.primary.opacity(0.3), radius: 15)
                .scaleEffect(animateIn ? 1.0 : 0.8)
                .opacity(animateIn ? 1 : 0)
            
            Spacer().frame(height: 24)
            
            // Description
            Text(profile.description)
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(animateIn ? 1 : 0)
            
            Spacer().frame(height: 32)
            
            // Gauge bars
            VStack(spacing: 20) {
                OnboardingGaugeBar(
                    label: "Lumi's anxiety level",
                    value: profile.anxietyLevel,
                    trailingLabel: anxietyLabel
                )
                
                OnboardingGaugeBar(
                    label: "Your peak risk window",
                    value: 0.75,
                    trailingLabel: profile.peakRiskLabel
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            .padding(.horizontal, 24)
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 20)
            
            Spacer()
            
            OnboardingCTAButton("I see it") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateIn = true
            }
        }
        .onDisappear {
            animateIn = false
        }
    }
    
    private var profilePetAsset: String {
        if screenTimeHours >= 7 {
            return "3_pet_sad"
        } else if screenTimeHours >= 4 {
            return "2_pet_neutral"
        } else {
            return "1_pet_happy"
        }
    }
    
    private var anxietyLabel: String {
        if profile.anxietyLevel >= 0.7 {
            return "High"
        } else if profile.anxietyLevel >= 0.4 {
            return "Medium"
        } else {
            return "Low"
        }
    }
}

#Preview {
    let profile = EmpathyProfile.compute(
        painPoint: .anxious,
        habitWindow: .night,
        screenTimeHours: 7
    )
    OnboardingProfileView(
        profile: profile,
        screenTimeHours: 7,
        onContinue: {}
    )
    .appBackground()
}
