import SwiftUI

struct OnboardingContainerView: View {
    @State private var manager = OnboardingManager()
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar + back button (hidden on first and processing/final screens)
            if shouldShowProgressBar {
                HStack(spacing: 12) {
                    if manager.currentPage > 0 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                manager.goBack()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.theme.primary)
                                .frame(width: 36, height: 36)
                        }
                    }
                    
                    OnboardingProgressBar(progress: manager.progress)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }
            
            // Page content
            TabView(selection: $manager.currentPage) {
                // Screens 1-4: Welcome / Story
                ForEach(0..<4, id: \.self) { index in
                    OnboardingWelcomeView(
                        page: OnboardingStoryPage.pages[index],
                        isFirstScreen: index == 0,
                        onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                    )
                    .tag(index)
                }
                
                // Screen 5: Personalization Intro
                OnboardingPersonalizationIntroView(
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(4)
                
                // Screen 6: Survey Q1 - Motivation
                OnboardingSurveyView(
                    headline: "Why do you want to change?",
                    options: OnboardingMotivation.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.motivation?.id },
                        set: { id in manager.motivation = OnboardingMotivation.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(5)
                
                // Screen 7: Survey Q2 - Pain Point
                OnboardingSurveyView(
                    headline: "How does your phone use affect you most?",
                    options: OnboardingPainPoint.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.painPoint?.id },
                        set: { id in manager.painPoint = OnboardingPainPoint.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(6)
                
                // Screen 8: Survey Q3 - Habit Window
                OnboardingSurveyView(
                    headline: "When do you reach for your phone the most?",
                    options: OnboardingHabitWindow.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.habitWindow?.id },
                        set: { id in manager.habitWindow = OnboardingHabitWindow.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(7)
                
                // Screen 9: Survey Q4 - Identity
                OnboardingSurveyView(
                    headline: "What describes you best?",
                    options: OnboardingIdentity.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.identity?.id },
                        set: { id in manager.identity = OnboardingIdentity.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(8)
                
                // Screen 10: Did You Know?
                OnboardingDidYouKnowView(
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(9)
                
                // Screen 11: Survey Q5 - Age
                OnboardingSurveyView(
                    headline: "How old are you?",
                    options: OnboardingAgeRange.allCases.map { (nil, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.ageRange?.id },
                        set: { id in manager.ageRange = OnboardingAgeRange.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(10)
                
                // Screen 12: Survey Q6 - Screen Time Slider
                OnboardingSliderView(
                    screenTimeHours: $manager.screenTimeHours,
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(11)
                
                // Screens 13-14: Processing Animation
                OnboardingProcessingView(
                    onComplete: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(12)
                
                // Screen 15: Empathy Profile
                OnboardingProfileView(
                    profile: manager.empathyProfile,
                    screenTimeHours: manager.screenTimeHours,
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(13)
                
                // Screen 20: Final CTA (Screen 14 here since we skip 16-19)
                OnboardingFinalView(
                    onSetup: {
                        manager.completeOnboarding()
                        onComplete()
                    }
                )
                .tag(14)
                
                // Placeholder for page count (to get 15 pages = index 0-14, plus tag 15 for totalPages=16)
                // The actual total is 15 screens (0-14), so we adjust totalPages
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: manager.currentPage)
            .ignoresSafeArea(.keyboard)
        }
        .appBackground()
    }
    
    private var shouldShowProgressBar: Bool {
        // Hide on first screen (landing), processing screen, and final screen
        manager.currentPage > 0 && manager.currentPage != 12 && manager.currentPage != 14
    }
}

// MARK: - Personalization Intro (Screen 5)

struct OnboardingPersonalizationIntroView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Image("1_pet_happy")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .shadow(color: Color.theme.primary.opacity(0.3), radius: 20)
            
            Spacer().frame(height: 32)
            
            Text("Let's understand your\nrelationship with your phone")
                .font(.appFont.largeTitle)
                .foregroundColor(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 12)
            
            Text("Your answers shape how Lumi responds to you")
                .font(.appFont.body)
                .foregroundColor(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            OnboardingCTAButton("Let's go") {
                onContinue()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    OnboardingContainerView(onComplete: {})
}
