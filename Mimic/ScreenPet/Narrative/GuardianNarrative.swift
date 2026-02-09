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
}
