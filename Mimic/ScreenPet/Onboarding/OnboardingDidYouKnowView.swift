import SwiftUI

struct OnboardingDidYouKnowView: View {
    let onContinue: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 24)
            
            // Headline
            Text("Did you know?")
                .font(.appFont.largeTitle)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(animateIn ? 1 : 0)
            
            Spacer().frame(height: 24)
            
            // Fact cards
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(DidYouKnowFact.facts.enumerated()), id: \.element.id) { index, fact in
                        DidYouKnowCard(emoji: fact.emoji, text: fact.text)
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 20)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.15),
                                value: animateIn
                            )
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
            
            OnboardingCTAButton("That's a lot") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation {
                animateIn = true
            }
        }
        .onDisappear {
            animateIn = false
        }
    }
}

#Preview {
    OnboardingDidYouKnowView(onContinue: {})
        .appBackground()
}
