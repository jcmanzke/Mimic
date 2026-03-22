import SwiftUI

struct OnboardingSurveyView: View {
    let headline: String
    let options: [(emoji: String?, label: String, id: String)]
    @Binding var selectedId: String?
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Small Lumi in top-right
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
            
            // Headline
            Text(headline)
                .font(.appFont.largeTitle)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 8)
            
            Spacer().frame(height: 24)
            
            // Options
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(options, id: \.id) { option in
                        OnboardingOptionCard(
                            emoji: option.emoji,
                            label: option.label,
                            isSelected: selectedId == option.id
                        ) {
                            selectedId = option.id
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // CTA
            OnboardingCTAButton("Continue", isEnabled: selectedId != nil) {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selected: String? = nil
        var body: some View {
            OnboardingSurveyView(
                headline: "Why do you want to change?",
                options: OnboardingMotivation.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                selectedId: $selected,
                onContinue: {}
            )
            .appBackground()
        }
    }
    return PreviewWrapper()
}
