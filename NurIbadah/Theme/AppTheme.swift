import SwiftUI

// MARK: - App Color Palette & Theme
enum AppTheme {
    // Primary Brand Colors (Modern Islamic Minimalist)
    static let primaryEmerald = Color("PrimaryEmerald", bundle: nil)
    static let primaryForest = Color(red: 0.08, green: 0.24, blue: 0.18) // #143D2E
    static let primarySage = Color(red: 0.22, green: 0.45, blue: 0.35)   // #387359
    static let accentGold = Color(red: 0.77, green: 0.63, blue: 0.35)    // #C5A059
    static let softGold = Color(red: 0.93, green: 0.86, blue: 0.70)      // #EDE0B2
    static let deepNavy = Color(red: 0.07, green: 0.12, blue: 0.18)      // #121F2E
    
    // Semantic Card Backgrounds
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.11, green: 0.13, blue: 0.15)
            : Color(red: 0.98, green: 0.98, blue: 0.99)
    }
    
    static func cardBorder(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.06)
    }
    
    static func subtleBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 0.06, green: 0.07, blue: 0.08)
            : Color(red: 0.96, green: 0.96, blue: 0.97)
    }
    
    static func textPrimary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white : Color(red: 0.10, green: 0.12, blue: 0.15)
    }
    
    static func textSecondary(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.65) : Color(red: 0.40, green: 0.43, blue: 0.48)
    }
    
    static func emeraldGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.24, blue: 0.18),
                Color(red: 0.14, green: 0.34, blue: 0.25)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func goldGradient() -> LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.85, green: 0.70, blue: 0.42),
                Color(red: 0.72, green: 0.58, blue: 0.30)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color Extension for Hex Initializer
extension Color {
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
