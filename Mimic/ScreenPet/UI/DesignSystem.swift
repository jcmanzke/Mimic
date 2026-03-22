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
    let primary = Color(hex: "EB5E55")      // Brand Red/Coral
    let secondary = Color(hex: "DDA0DD")    // Lavender - accent, stats
    let warning = Color(hex: "FFB347")      // Peach - warning states
    let critical = Color(hex: "FF6B6B")     // Coral - critical, alerts
    
    // Background gradient
    let backgroundStart = Color(hex: "F8F9FA")  // Neutral background
    let backgroundEnd = Color(hex: "F8F9FA")    // Neutral background
    
    // Glass card
    let cardBackground = Color.white.opacity(0.8)
    let cardBorder = Color.white.opacity(0.5)
    
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
    // Display — hero/feature numbers (vitality score)
    let display = Font.custom("PlusJakartaSans-Regular", size: 40).weight(.bold)
    // Large Title — page-level headings (pet name)
    let largeTitle = Font.custom("PlusJakartaSans-Regular", size: 28).weight(.bold)
    // Title — card-level large values (stat cards)
    let title = Font.custom("PlusJakartaSans-Regular", size: 22).weight(.bold)
    // Headline — section headers, button labels
    let headline = Font.custom("PlusJakartaSans-Regular", size: 15).weight(.semibold)
    // Subheadline — secondary labels, small buttons
    let subheadline = Font.custom("PlusJakartaSans-Regular", size: 13).weight(.semibold)
    // Body — primary readable text
    let body = Font.custom("PlusJakartaSans-Regular", size: 15)
    // Caption — timestamps, subtitles, metadata
    let caption = Font.custom("PlusJakartaSans-Regular", size: 12)
    // Overline — section group labels (e.g. "SELECTED APPS")
    let overline = Font.custom("PlusJakartaSans-Regular", size: 11).weight(.semibold)
}

// MARK: - View Modifiers

/// Glass card effect with blur and subtle border
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    
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
                // Appended strictly to the background gradient, not the content's outer bounds
                .ignoresSafeArea()
            )
    }
}

extension View {
    /// Apply glassmorphism card styling
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
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
                RoundedRectangle(cornerRadius: 12)
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
                RoundedRectangle(cornerRadius: 12)
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.theme.cardBorder, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - Onboarding Components

/// Full-width salmon CTA button for onboarding
struct OnboardingCTAButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void
    
    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appFont.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isEnabled ? Color.theme.primary : Color.theme.textSecondary.opacity(0.3))
                )
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

/// Thin salmon progress bar for onboarding
struct OnboardingProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.theme.textSecondary.opacity(0.12))
                    .frame(height: 4)
                
                Capsule()
                    .fill(Color.theme.primary)
                    .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 4)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
    }
}

/// Selectable option card for survey screens
struct OnboardingOptionCard: View {
    let emoji: String?
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.system(size: 22))
                }
                
                Text(label)
                    .font(.appFont.body)
                    .foregroundColor(Color.theme.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.theme.primary.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.theme.primary : Color.theme.textSecondary.opacity(0.15), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

/// Notification-style pill badge for the science/reframe screen
struct NotificationBadge: View {
    let text: String
    let dotColor: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
            
            Text(text)
                .font(.appFont.caption)
                .foregroundColor(Color.theme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }
}

/// Info card for "Did You Know" screen
struct DidYouKnowCard: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))
            
            Text(text)
                .font(.appFont.body)
                .foregroundColor(Color.theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
    }
}

/// Gauge bar for profile results
struct OnboardingGaugeBar: View {
    let label: String
    let value: Double  // 0.0 to 1.0
    let trailingLabel: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.textSecondary)
                Spacer()
                Text(trailingLabel)
                    .font(.appFont.caption)
                    .foregroundColor(Color.theme.primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.theme.textSecondary.opacity(0.12))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.theme.primary)
                        .frame(width: max(0, geometry.size.width * CGFloat(value)), height: 8)
                }
            }
            .frame(height: 8)
        }
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
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(value)
                .font(.appFont.largeTitle)
                .foregroundColor(accentColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(subtitle)
                .font(.appFont.caption)
                .foregroundColor(Color.theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .padding(16)
        .glassCard(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
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
