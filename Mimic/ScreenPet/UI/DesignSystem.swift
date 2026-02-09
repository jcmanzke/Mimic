import SwiftUI

// MARK: - Color Theme

extension Color {
    static let theme = ColorTheme()
    
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColorTheme {
    // Primary palette
    let primary = Color(hex: "A8E6CF")      // Mint - healthy, positive
    let secondary = Color(hex: "DDA0DD")    // Lavender - accent, stats
    let warning = Color(hex: "FFB347")      // Peach - warning states
    let critical = Color(hex: "FF6B6B")     // Coral - critical, alerts
    
    // Background gradient
    let backgroundStart = Color(hex: "F5E6D3")  // Warm cream
    let backgroundEnd = Color(hex: "E8D5E3")    // Soft pink
    
    // Glass card
    let cardBackground = Color.white.opacity(0.6)
    let cardBorder = Color.white.opacity(0.3)
    
    // Text
    let textPrimary = Color(hex: "2D3436")   // Charcoal
    let textSecondary = Color(hex: "636E72") // Gray
    
    // State-based colors
    func colorForHealth(_ health: Double) -> Color {
        switch health {
        case 0.8...1.0: return primary      // Happy
        case 0.4..<0.8: return secondary    // Neutral
        case 0.1..<0.4: return warning      // Sad
        default: return critical             // Critical
        }
    }
}

// MARK: - Typography

extension Font {
    static let appFont = AppFontTheme()
}

struct AppFontTheme {
    let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
    let title = Font.system(size: 24, weight: .semibold, design: .rounded)
    let headline = Font.system(size: 17, weight: .semibold, design: .default)
    let body = Font.system(size: 15, weight: .regular, design: .default)
    let caption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - View Modifiers

/// Glass card effect with blur and subtle border
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.theme.cardBorder, lineWidth: 1)
                    )
            )
    }
}

/// App gradient background
struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [Color.theme.backgroundStart, Color.theme.backgroundEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    /// Apply glassmorphism card styling
    func glassCard(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
    
    /// Apply app gradient background
    func appBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont.headline)
            .foregroundColor(Color.theme.textPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appFont.headline)
            .foregroundColor(Color.theme.textPrimary)
            .frame(width: 48, height: 48)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(Color.theme.cardBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Reusable Components

/// Stat card with accent color
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appFont.caption)
                .foregroundColor(Color.theme.textSecondary)
            
            Text(value)
                .font(.appFont.largeTitle)
                .foregroundColor(accentColor)
            
            Text(subtitle)
                .font(.appFont.caption)
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(width: 160, height: 100, alignment: .leading)
        .padding(16)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(accentColor.opacity(0.3), lineWidth: 2)
                .padding(1)
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        Text("ScreenPet")
            .font(.appFont.largeTitle)
            .foregroundColor(Color.theme.textPrimary)
        
        HStack(spacing: 16) {
            StatCard(
                title: "Health",
                value: "85%",
                subtitle: "Great!",
                accentColor: Color.theme.primary
            )
            
            StatCard(
                title: "Streak",
                value: "7",
                subtitle: "Days protected",
                accentColor: Color.theme.secondary
            )
        }
        
        Button("Start Session") {}
            .buttonStyle(PrimaryButtonStyle())
        
        Button("Settings") {}
            .buttonStyle(SecondaryButtonStyle())
        
        Button {
        } label: {
            Image(systemName: "gear")
        }
        .buttonStyle(IconButtonStyle())
    }
    .padding()
    .appBackground()
}
