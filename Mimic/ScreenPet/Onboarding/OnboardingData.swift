import SwiftUI

// MARK: - Survey Option Enums

enum OnboardingMotivation: String, CaseIterable, Identifiable {
    case focus = "Improve focus"
    case scrolling = "Reduce mindless scrolling"
    case sleep = "Sleep better"
    case present = "Be more present"
    case productive = "Be more productive"
    case curious = "Just curious"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .focus: return "🧠"
        case .scrolling: return "😤"
        case .sleep: return "😴"
        case .present: return "🫂"
        case .productive: return "⚡"
        case .curious: return "🔍"
        }
    }
}

enum OnboardingPainPoint: String, CaseIterable, Identifiable {
    case noFocus = "I can't focus on anything"
    case anxious = "I feel anxious without it"
    case badSleep = "Bad sleep / doomscrolling at night"
    case procrastination = "I keep procrastinating"
    case mentallyFried = "My memory/attention feels shot"
    case lessPresent = "I'm less present with people I love"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .noFocus: return "🤯"
        case .anxious: return "😰"
        case .badSleep: return "😴"
        case .procrastination: return "📉"
        case .mentallyFried: return "🧠"
        case .lessPresent: return "👨‍👩‍👧"
        }
    }
}

enum OnboardingHabitWindow: String, CaseIterable, Identifiable {
    case morning = "First thing in the morning"
    case workday = "During the workday"
    case evening = "In the evenings"
    case night = "Late at night / bed"
    case allDay = "All day, constantly"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .morning: return "🌅"
        case .workday: return "☁️"
        case .evening: return "🌆"
        case .night: return "🌑"
        case .allDay: return "🔁"
        }
    }
}

enum OnboardingIdentity: String, CaseIterable, Identifiable {
    case builder = "Builder / Developer"
    case student = "Student"
    case athlete = "Athlete / Active lifestyle"
    case parent = "Parent"
    case professional = "Professional / Knowledge worker"
    case livingBetter = "Just trying to live better"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .builder: return "🧑‍💻"
        case .student: return "🎓"
        case .athlete: return "🏋️"
        case .parent: return "🧑‍👧"
        case .professional: return "🏢"
        case .livingBetter: return "🌱"
        }
    }
}

enum OnboardingAgeRange: String, CaseIterable, Identifiable {
    case under18 = "Under 18"
    case age18to24 = "18–24"
    case age25to34 = "25–34"
    case age35to44 = "35–44"
    case age45to54 = "45–54"
    case age55plus = "55+"
    
    var id: String { rawValue }
}

// MARK: - Empathy Profile

struct EmpathyProfile {
    let title: String
    let description: String
    let anxietyLevel: Double  // 0.0 to 1.0
    let peakRiskLabel: String
    
    static func compute(
        painPoint: OnboardingPainPoint?,
        habitWindow: OnboardingHabitWindow?,
        screenTimeHours: Double
    ) -> EmpathyProfile {
        let title: String
        let peakRisk: String
        
        switch habitWindow {
        case .night:
            title = "The Nighttime Drifter"
            peakRisk = "Late Night"
        case .morning:
            title = "The Morning Lurker"
            peakRisk = "Mornings"
        case .evening:
            title = "The Evening Scroller"
            peakRisk = "Evenings"
        case .workday:
            title = "The Distracted Worker"
            peakRisk = "Daytime"
        case .allDay:
            title = "The Always-On Mind"
            peakRisk = "All Day"
        default:
            title = "The Stress Scroller"
            peakRisk = "Varies"
        }
        
        let anxietyLevel = min(1.0, screenTimeHours / 12.0)
        
        let description: String
        switch habitWindow {
        case .night:
            description = "Your biggest attention leak happens at night. Lumi will help protect your evenings and improve your sleep quality."
        case .morning:
            description = "You tend to reach for your phone first thing. Lumi will help you start your mornings with intention."
        case .evening:
            description = "Evenings are when you lose the most presence. Lumi will help you reclaim your nights."
        case .workday:
            description = "Your focus gets fragmented during work hours. Lumi will help you stay on track when it matters most."
        case .allDay:
            description = "Your phone is a constant companion. Lumi will gently remind you to take breaks throughout the day."
        default:
            description = "Lumi will learn your patterns and help you build a healthier relationship with your phone."
        }
        
        return EmpathyProfile(
            title: title,
            description: description,
            anxietyLevel: anxietyLevel,
            peakRiskLabel: peakRisk
        )
    }
}

// MARK: - Welcome Screen Data

struct OnboardingStoryPage {
    let headline: String
    let body: String
    let petAsset: String
    let ctaText: String
    let showNotificationBadges: Bool
    
    static let pages: [OnboardingStoryPage] = [
        OnboardingStoryPage(
            headline: "Meet Lumi.",
            body: "Lumi feels everything you feel on your phone.",
            petAsset: "1_pet_happy",
            ctaText: "Say hello →",
            showNotificationBadges: false
        ),
        OnboardingStoryPage(
            headline: "Lumi is a mirror.",
            body: "When you scroll endlessly, Lumi gets anxious. When you're present, Lumi thrives. Lumi doesn't judge — Lumi just reflects.",
            petAsset: "1_pet_happy",
            ctaText: "Tell me more",
            showNotificationBadges: false
        ),
        OnboardingStoryPage(
            headline: "Would you do this\nto Lumi?",
            body: "Most of us would never let someone we care about feel restless, anxious, and drained — but that's exactly how our phones leave us feeling every day.",
            petAsset: "2_pet_neutral",
            ctaText: "I wouldn't",
            showNotificationBadges: false
        ),
        OnboardingStoryPage(
            headline: "You're not weak.\nYour attention is\nbeing harvested.",
            body: "Apps are engineered to steal your focus. Mimic doesn't block anything — it helps you feel what your phone actually costs you.",
            petAsset: "3_pet_sad",
            ctaText: "Got it",
            showNotificationBadges: true
        )
    ]
}

// MARK: - Did You Know Data

struct DidYouKnowFact: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
    
    static let facts: [DidYouKnowFact] = [
        DidYouKnowFact(emoji: "⏰", text: "The average person spends 4+ hours/day on their phone — that's 60 days a year"),
        DidYouKnowFact(emoji: "📱", text: "We check our phones ~96 times a day, often without even realizing"),
        DidYouKnowFact(emoji: "🧠", text: "Chronic scrolling rewires your brain's reward system, making real life feel boring"),
        DidYouKnowFact(emoji: "💤", text: "Blue light and notifications before bed reduce sleep quality by up to 30%")
    ]
}

// MARK: - Onboarding Manager

@Observable
class OnboardingManager {
    // Total number of onboarding pages
    static let totalPages = 12
    
    var currentPage: Int = 0
    
    // Survey answers
    var motivation: OnboardingMotivation?
    var painPoint: OnboardingPainPoint?
    var habitWindow: OnboardingHabitWindow?
    var identity: OnboardingIdentity?
    var ageRange: OnboardingAgeRange?
    var screenTimeHours: Double = 5.0
    
    // Computed profile
    var empathyProfile: EmpathyProfile {
        EmpathyProfile.compute(
            painPoint: painPoint,
            habitWindow: habitWindow,
            screenTimeHours: screenTimeHours
        )
    }
    
    // Progress (0.0 to 1.0)
    var progress: Double {
        Double(currentPage) / Double(Self.totalPages - 1)
    }
    
    func advance() {
        if currentPage < Self.totalPages - 1 {
            currentPage += 1
        }
    }
    
    func goBack() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
