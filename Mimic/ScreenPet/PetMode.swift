import Foundation

/// Pet narrative mode selection
enum PetMode: String, CaseIterable, Codable {
    case reflection = "reflection"
    case guardian = "guardian"
    case echo = "echo"
    
    var displayName: String {
        switch self {
        case .reflection: return "The Reflection"
        case .guardian: return "The Guardian"
        case .echo: return "The Echo"
        }
    }
    
    var petName: String {
        switch self {
        case .reflection: return "Mimic"
        case .guardian: return "Lumi"
        case .echo: return "Echo"
        }
    }
    
    var description: String {
        switch self {
        case .reflection:
            return "Your digital twin. When you scroll, Mimic suffers. Take care of Mimic, and you take care of yourself."
        case .guardian:
            return "A vulnerable creature you've adopted. Protect Lumi from the digital chaos."
        case .echo:
            return "Your future self. Every mindful moment makes Echo more real."
        }
    }
}
