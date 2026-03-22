import SwiftUI

struct OnboardingWelcomeView: View {
    let page: OnboardingStoryPage
    let isFirstScreen: Bool
    let onContinue: () -> Void
    
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Pet image
            ZStack {
                // Soft glow behind pet
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.theme.primary.opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)
                
                Image(page.petAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(color: Color.theme.primary.opacity(0.3), radius: 20)
                    .scaleEffect(animateIn ? 1.0 : 0.8)
                    .opacity(animateIn ? 1 : 0)
                
                // Notification badges for the science/reframe screen
                if page.showNotificationBadges {
                    notificationBadges
                }
            }
            
            Spacer().frame(height: 32)
            
            // Headline
            Text(page.headline)
                .font(.appFont.largeTitle)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
            
            Spacer().frame(height: 12)
            
            // Body
            Text(page.body)
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 20)
            
            Spacer()
            
            // CTA
            OnboardingCTAButton(page.ctaText) {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, isFirstScreen ? 8 : 40)
            
            // Terms footer on first screen only
            if isFirstScreen {
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animateIn = true
            }
        }
        .onDisappear {
            animateIn = false
        }
    }
    
    // MARK: - Notification Badges (Screen 4)
    
    private var notificationBadges: some View {
        Group {
            NotificationBadge(text: "Someone liked your post", dotColor: .blue)
                .offset(x: -80, y: -90)
                .rotationEffect(.degrees(-8))
            
            NotificationBadge(text: "Don't miss this", dotColor: .red)
                .offset(x: 90, y: -60)
                .rotationEffect(.degrees(5))
            
            NotificationBadge(text: "You have 3 new followers", dotColor: .green)
                .offset(x: -60, y: 90)
                .rotationEffect(.degrees(3))
            
            NotificationBadge(text: "Trending now", dotColor: .orange)
                .offset(x: 80, y: 70)
                .rotationEffect(.degrees(-4))
        }
        .opacity(animateIn ? 1 : 0)
    }
}

#Preview {
    OnboardingWelcomeView(
        page: OnboardingStoryPage.pages[0],
        isFirstScreen: true,
        onContinue: {}
    )
    .appBackground()
}
