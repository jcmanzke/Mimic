import SwiftUI

struct OnboardingSliderView: View {
    @Binding var screenTimeHours: Double
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Small Lumi
            HStack {
                Spacer()
                Image("1_pet_happy")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .opacity(0.8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            Spacer()
            
            // Headline
            Text("How much time do you\nspend on your phone daily?")
                .font(.appFont.largeTitle)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 8)
            
            Text("Be honest — Lumi won't judge 🐾")
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
            
            Spacer().frame(height: 40)
            
            // Large hour display
            Text("\(Int(screenTimeHours)) hours")
                .font(.custom("PlusJakartaSans-Bold", size: 48))
                .foregroundColor(Color.theme.textPrimary)
                .contentTransition(.numericText())
                .animation(.snappy, value: Int(screenTimeHours))
            
            Spacer().frame(height: 32)
            
            // Slider
            VStack(spacing: 8) {
                Slider(value: $screenTimeHours, in: 0...12, step: 1)
                    .accentColor(Color.theme.primary)
                    .padding(.horizontal, 24)
                
                HStack {
                    Text("0h")
                        .font(.appFont.caption)
                        .foregroundColor(Color.theme.textSecondary)
                    Spacer()
                    Text("12h+")
                        .font(.appFont.caption)
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.horizontal, 24)
            }
            
            Spacer().frame(height: 24)
            
            // Dynamic feedback
            Text(feedbackText)
                .font(.appFont.body)
                .foregroundColor(Color.theme.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .animation(.easeInOut, value: feedbackText)
            
            Spacer()
            
            OnboardingCTAButton("That's me") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private var feedbackText: String {
        switch screenTimeHours {
        case 0..<2:
            return "You're doing better than most!"
        case 2..<4:
            return "That's pretty average — Lumi wants to help you go further"
        case 4..<7:
            return "That's a big chunk of your waking life"
        default:
            return "Lumi really needs you right now 🥺"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var hours: Double = 5.0
        var body: some View {
            OnboardingSliderView(screenTimeHours: $hours, onContinue: {})
                .appBackground()
        }
    }
    return PreviewWrapper()
}
