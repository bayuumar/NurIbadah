import SwiftUI

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    var lineWidth: CGFloat = 6
    var primaryColor: Color = AppTheme.accentGold
    var trackColor: Color = Color.secondary.opacity(0.18)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(max(progress, 0.0), 1.0)))
                .stroke(
                    primaryColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.25), value: progress)
        }
    }
}
