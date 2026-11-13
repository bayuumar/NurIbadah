import SwiftUI

// MARK: - Modern Card Styling Modifier
struct ModernCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 18
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppTheme.cardBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.cardBorder(for: colorScheme), lineWidth: 1)
            )
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.04),
                radius: 8,
                x: 0,
                y: 3
            )
    }
}

extension View {
    func modernCard(cornerRadius: CGFloat = 18, padding: CGFloat = 16) -> some View {
        self.modifier(ModernCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
