import SwiftUI

// MARK: - Mood / Category Badge
struct MoodBadgeView: View {
    let category: MuhasabahCategory
    var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.iconName)
                .font(.system(size: 11, weight: .semibold))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            isSelected
                ? category.color.opacity(0.85)
                : category.color.opacity(0.15)
        )
        .foregroundColor(
            isSelected
                ? Color.white
                : category.color
        )
        .clipShape(Capsule())
    }
}
