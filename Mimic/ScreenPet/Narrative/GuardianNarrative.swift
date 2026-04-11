import Foundation

/// Narrative messages for Guardian mode (Lumi)
/// The user is a protector; Lumi is a vulnerable creature they've adopted.
struct GuardianNarrative {
    
    /// Message based on current health level
    static func messageForHealth(_ health: Double) -> String {
        switch health {
        case 0.8...1.0:
            return "Lumi feels safe and happy! 💚"
        case 0.6..<0.8:
            return "Lumi is resting peacefully."
        case 0.4..<0.6:
            return "Lumi senses something unsettling..."
        case 0.25..<0.4:
            return "Lumi is hiding. The chaos is growing."
        case 0.1..<0.25:
            return "Lumi is overwhelmed. Please help..."
        default:
            return "Lumi is fading away... 🥺"
        }
    }
    
    /// Message when user opens a distracting app
    static func onDistractingAppOpened() -> String {
        return "Lumi senses something draining..."
    }
    
    /// Message when health drops to a threshold
    static func onHealthThreshold(_ health: Double) -> String {
        switch health {
        case 0.75:
            return "Lumi is getting nervous. The noise is building."
        case 0.50:
            return "Lumi curls into a ball. It's too much."
        case 0.25:
            return "⚠️ Lumi needs you. Put your phone down for a bit."
        default:
            return messageForHealth(health)
        }
    }
    
    /// Message when user locks phone / recovers
    static func onRecovery(_ minutes: Double) -> String {
        if minutes >= 30 {
            return "Lumi stretches and smiles. The sanctuary feels peaceful again! ✨"
        } else if minutes >= 10 {
            return "Lumi peeks out. It's getting calmer."
        } else {
            return "Lumi notices the quiet. 💚"
        }
    }
    
    /// Message for rescue mission prompt
    static func rescuePrompt() -> String {
        return "Lumi needs a break. Can you put your phone down for 10 minutes?"
    }
    
    /// Guardian streak message
    static func streakMessage(_ days: Int) -> String {
        switch days {
        case 0:
            return "Start protecting Lumi today!"
        case 1:
            return "1 day protected. Lumi trusts you."
        case 7:
            return "7 days! Lumi is thriving! 🌱"
        case 30:
            return "30 days! The sanctuary is flourishing! 🌳"
        default:
            return "\(days) days protected. Lumi is grateful. 💚"
        }
    }
    
    // MARK: - Notification Copy
    
    /// Returns the notification title for a given notification type
    static func notificationTitle(for type: PetNotificationType) -> String {
        switch type {
        case .healthThreshold:
            return "Lumi's Sanctuary"
        case .criticalAlert:
            return "🚨 Lumi is fading"
        case .recoveryCelebration:
            return "Lumi is recovering ✨"
        case .dailySummary:
            return "Your Day with Lumi"
        case .morningEncouragement:
            return "Good Morning 🌅"
        }
    }
    
    /// Returns the notification body for a given notification type and health context
    ///
    /// - Parameters:
    ///   - type: The notification type
    ///   - health: Context-dependent value:
    ///     - For `.healthThreshold`: the threshold that was crossed (0.75, 0.50, 0.25, 0.10)
    ///     - For `.criticalAlert`: ignored (always 0)
    ///     - For `.recoveryCelebration`: recovery minutes / 60 (to reuse recovery copy)
    ///     - For `.dailySummary`: current health (or -1 for generic)
    ///     - For `.morningEncouragement`: ignored
    static func notificationBody(for type: PetNotificationType, health: Double) -> String {
        switch type {
        case .healthThreshold:
            return healthThresholdBody(threshold: health)
        case .criticalAlert:
            return criticalAlertBody()
        case .recoveryCelebration:
            return recoveryCelebrationBody(minutes: health * 60)
        case .dailySummary:
            return dailySummaryBody(health: health)
        case .morningEncouragement:
            return morningEncouragementBody()
        }
    }
    
    // MARK: - Private Notification Body Helpers
    
    private static func healthThresholdBody(threshold: Double) -> String {
        switch threshold {
        case 0.75:
            return "Lumi is getting nervous. The noise is building. 🫣"
        case 0.50:
            return "Lumi curls into a ball. It's too much. Can you take a break?"
        case 0.25:
            return "⚠️ Lumi needs you. Put your phone down for a bit."
        case 0.10:
            return "🆘 Lumi is barely holding on. Please, give them a moment of peace."
        default:
            return messageForHealth(threshold)
        }
    }
    
    private static func criticalAlertBody() -> String {
        return "Lumi has faded away... But don't give up — a new day starts at 4 AM. 💔"
    }
    
    private static func recoveryCelebrationBody(minutes: Double) -> String {
        if minutes >= 30 {
            return "Lumi stretches and smiles. The sanctuary feels peaceful again! ✨"
        } else if minutes >= 10 {
            return "Lumi peeks out. The quiet is helping. Keep going! 💚"
        } else {
            return "Lumi notices the calm. Every minute counts. 🌱"
        }
    }
    
    private static func dailySummaryBody(health: Double) -> String {
        if health >= 0.8 {
            return "Amazing day! Lumi's vitality is at \(Int(health * 100))%. The sanctuary is thriving. 🌳"
        } else if health >= 0.5 {
            return "Lumi finished the day at \(Int(health * 100))%. Not bad — tomorrow you can do even better!"
        } else if health >= 0.25 {
            return "Lumi struggled today (\(Int(health * 100))%). Tomorrow is a fresh start. 🌅"
        } else if health >= 0 {
            return "Tough day for Lumi (\(Int(health * 100))%). But every sunrise is a second chance. 💚"
        } else {
            // Generic fallback when health isn't available
            return "Time to reflect on your day with Lumi. See how you did! 📊"
        }
    }
    
    private static func morningEncouragementBody() -> String {
        let messages = [
            "Lumi is refreshed and ready for a new day! 🌅",
            "A new day, a fresh sanctuary. Lumi believes in you! 💚",
            "Good morning! Lumi woke up happy. Let's keep it that way! ☀️",
            "The sanctuary is peaceful this morning. Let's protect it together. 🛡️",
            "Lumi yawns and stretches. Ready to face the day with you! 🌱"
        ]
        // Rotate based on day of year for variety without randomness issues
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return messages[dayOfYear % messages.count]
    }
}
