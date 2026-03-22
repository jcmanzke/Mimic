import SwiftUI

struct OnboardingContainerView: View {
    @State private var manager = OnboardingManager()
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation row
            HStack(spacing: 12) {
                if shouldShowProgressBar {
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
                } else {
                    Spacer()
                }
                
                #if DEBUG
                if manager.currentPage == 0 {
                    Button("Skip →") {
                        onComplete()
                    }
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.theme.textSecondary.opacity(0.1))
                    )
                }
                #endif
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 4)
            
            // Page content
            TabView(selection: $manager.currentPage) {
                
                // Tag 0: Welcome story (4 sub-pages handled internally — Lumi stays, text slides)
                OnboardingWelcomeContainerView(
                    isFirstScreen: true,
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(0)
                
                // Tag 1: Personalization Intro
                OnboardingPersonalizationIntroView(
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(1)
                
                // Tag 2: Survey Q1 - Motivation
                OnboardingSurveyView(
                    headline: "Why do you want to change?",
                    options: OnboardingMotivation.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.motivation?.id },
                        set: { id in manager.motivation = OnboardingMotivation.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(2)
                
                // Tag 3: Survey Q2 - Pain Point
                OnboardingSurveyView(
                    headline: "How does your phone use affect you most?",
                    options: OnboardingPainPoint.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.painPoint?.id },
                        set: { id in manager.painPoint = OnboardingPainPoint.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(3)
                
                // Tag 4: Survey Q3 - Habit Window
                OnboardingSurveyView(
                    headline: "When do you reach for your phone the most?",
                    options: OnboardingHabitWindow.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.habitWindow?.id },
                        set: { id in manager.habitWindow = OnboardingHabitWindow.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(4)
                
                // Tag 5: Survey Q4 - Identity
                OnboardingSurveyView(
                    headline: "What describes you best?",
                    options: OnboardingIdentity.allCases.map { ($0.emoji, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.identity?.id },
                        set: { id in manager.identity = OnboardingIdentity.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(5)
                
                // Tag 6: Did You Know?
                OnboardingDidYouKnowView(
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(6)
                
                // Tag 7: Survey Q5 - Age
                OnboardingSurveyView(
                    headline: "How old are you?",
                    options: OnboardingAgeRange.allCases.map { (nil, $0.rawValue, $0.id) },
                    selectedId: Binding(
                        get: { manager.ageRange?.id },
                        set: { id in manager.ageRange = OnboardingAgeRange.allCases.first { $0.id == id } }
                    ),
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(7)
                
                // Tag 8: Survey Q6 - Screen Time Slider
                OnboardingSliderView(
                    screenTimeHours: $manager.screenTimeHours,
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(8)
                
                // Tag 9: Processing Animation (auto-advances)
                OnboardingProcessingView(
                    onComplete: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(9)
                
                // Tag 10: Empathy Profile
                OnboardingProfileView(
                    profile: manager.empathyProfile,
                    screenTimeHours: manager.screenTimeHours,
                    onContinue: { withAnimation(.easeInOut(duration: 0.3)) { manager.advance() } }
                )
                .tag(10)
                
                // Tag 11: Final CTA
                OnboardingFinalView(
                    onSetup: {
                        manager.completeOnboarding()
                        onComplete()
                    }
                )
                .tag(11)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(.keyboard)
        }
        .appBackground()
    }
    
    private var shouldShowProgressBar: Bool {
        // Hide on welcome (page 0), processing (page 9), and final (page 11)
        manager.currentPage > 0 && manager.currentPage != 9 && manager.currentPage != 11
    }
}

// MARK: - Personalization Intro (Tag 1)

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
