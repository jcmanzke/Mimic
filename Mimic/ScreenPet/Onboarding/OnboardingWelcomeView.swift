import SwiftUI

// MARK: - Welcome Container (handles all 4 story sub-pages internally)

struct OnboardingWelcomeContainerView: View {
    let isFirstScreen: Bool
    let onContinue: () -> Void
    
    @State private var subPage = 0
    
    private var page: OnboardingStoryPage { OnboardingStoryPage.pages[subPage] }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Lumi section — stays in place, only cross-fades if pet asset changes
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.theme.primary.opacity(0.15), Color.clear],
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
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: page.petAsset)
                
                if page.showNotificationBadges {
                    notificationBadges
                        .transition(.opacity)
                }
            }
            
            Spacer().frame(height: 32)
            
            // Text section — slides in from the right on each sub-page change
            VStack(spacing: 12) {
                Text(page.headline)
                    .font(.appFont.largeTitle)
                    .foregroundColor(Color.theme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.body)
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .id(subPage) // new ID forces SwiftUI to apply the transition
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            
            Spacer()
            
            // CTA
            OnboardingCTAButton(page.ctaText) {
                advanceSubPage()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, isFirstScreen && subPage == 0 ? 8 : 40)
            
            // Terms footer — only on landing (sub-page 0)
            if subPage == 0 {
                Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
                    .transition(.opacity)
            }
        }
    }
    
    private func advanceSubPage() {
        if subPage < OnboardingStoryPage.pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                subPage += 1
            }
        } else {
            onContinue()
        }
    }
    
    // MARK: - Notification Badges (shown on sub-page 3)
    
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
    }
}

#Preview {
    OnboardingWelcomeContainerView(isFirstScreen: true, onContinue: {})
        .appBackground()
}
