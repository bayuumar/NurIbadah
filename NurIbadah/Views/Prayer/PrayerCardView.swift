import SwiftUI

// MARK: - Single Prayer Card View
struct PrayerCardView: View {
    let prayer: PrayerType
    let timeString: String
    let isCurrent: Bool
    let isNext: Bool
    let isNotificationEnabled: Bool
    let onToggleNotification: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 42, height: 42)
                
                Image(systemName: prayer.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconForegroundColor)
            }
            
            // Name & Arabic Name
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(prayer.displayName)
                        .font(.system(size: 16, weight: isNext ? .bold : .medium))
                        .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    
                    if isNext {
                        Text("Berikutnya")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.accentGold)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    } else if isCurrent {
                        Text("Saat Ini")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.primarySage)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Text(prayer.arabicName)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time
            Text(timeString)
                .font(.system(size: 18, weight: isNext ? .bold : .semibold, design: .rounded))
                .foregroundColor(isNext ? AppTheme.accentGold : AppTheme.textPrimary(for: colorScheme))
            
            // Notification Bell Toggle (hanya untuk sholat fardhu)
            if prayer.isFardhu {
                Button(action: onToggleNotification) {
                    Image(systemName: isNotificationEnabled ? "bell.fill" : "bell.slash")
                        .font(.system(size: 15))
                        .foregroundColor(isNotificationEnabled ? AppTheme.primarySage : Color.secondary.opacity(0.4))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            } else {
                // Spacer placeholder agar alignment tetap rapi
                Color.clear
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(cardBorderColor, lineWidth: isNext ? 1.5 : 1.0)
        )
    }
    
    private var cardBackground: Color {
        if isNext {
            return colorScheme == .dark
                ? AppTheme.accentGold.opacity(0.12)
                : AppTheme.accentGold.opacity(0.08)
        }
        return AppTheme.cardBackground(for: colorScheme)
    }
    
    private var cardBorderColor: Color {
        if isNext {
            return AppTheme.accentGold.opacity(0.5)
        }
        return AppTheme.cardBorder(for: colorScheme)
    }
    
    private var iconBackgroundColor: Color {
        if isNext {
            return AppTheme.accentGold.opacity(0.2)
        }
        return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04)
    }
    
    private var iconForegroundColor: Color {
        if isNext {
            return AppTheme.accentGold
        }
        return prayer.color
    }
}
