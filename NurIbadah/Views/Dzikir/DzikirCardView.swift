import SwiftUI

// MARK: - Dzikir Card View dengan Interactive Digital Tasbih
struct DzikirCardView: View {
    let item: DzikirItem
    let arabicFontSize: Double
    let onIncrement: () -> Void
    let onReset: () -> Void
    let onOpenFocus: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingTranslation: Bool = true
    @State private var isShowingLatin: Bool = true
    @State private var isShowingFadhilah: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header Kartu: Judul, Target Bacaan, dan Tombol Fokus
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    
                    HStack(spacing: 6) {
                        Text(item.source)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Target Tag
                HStack(spacing: 4) {
                    Text("\(item.targetCount)x")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(item.isCompleted ? Color.green.opacity(0.18) : AppTheme.accentGold.opacity(0.18))
                .foregroundColor(item.isCompleted ? Color.green : AppTheme.accentGold)
                .clipShape(Capsule())
                
                // Tombol Mode Fokus
                Button(action: onOpenFocus) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(6)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            
            // Teks Arab (RTL, Line Spacing Nyaman, Ukuran Font Dinamis)
            Text(item.arabicText)
                .font(.system(size: arabicFontSize, weight: .regular, design: .serif))
                .multilineTextAlignment(.trailing)
                .lineSpacing(10)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                .padding(.vertical, 6)
            
            // Transliterasi Latin
            if isShowingLatin && !item.latinText.isEmpty {
                Text(item.latinText)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .italic()
                    .foregroundColor(AppTheme.primarySage)
                    .lineSpacing(4)
            }
            
            // Terjemahan Bahasa Indonesia
            if isShowingTranslation && !item.translation.isEmpty {
                Text(item.translation)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(AppTheme.textSecondary(for: colorScheme))
                    .lineSpacing(3)
            }
            
            // Keutamaan (Fadhilah) jika tersedia
            if let fadhilah = item.fadhilah {
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowingFadhilah.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                            Text(isShowingFadhilah ? "Sembunyikan Keutamaan" : "Lihat Keutamaan (Fadhilah)")
                                .font(.system(size: 12, weight: .semibold))
                            Image(systemName: isShowingFadhilah ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(AppTheme.accentGold)
                    }
                    
                    if isShowingFadhilah {
                        Text(fadhilah)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.top, 2)
                    }
                }
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // Interactive Tasbih Area
            HStack(spacing: 16) {
                // Tombol Reset
                Button(action: onReset) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(item.currentCount > 0 ? .red.opacity(0.8) : .secondary.opacity(0.4))
                        .frame(width: 44, height: 44)
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(Circle())
                }
                .disabled(item.currentCount == 0)
                
                // Area Tap Tasbih Utama (Sentuh untuk menghitung)
                Button(action: onIncrement) {
                    HStack(spacing: 12) {
                        ZStack {
                            CircularProgressView(
                                progress: item.progressFraction,
                                lineWidth: 4,
                                primaryColor: item.isCompleted ? Color.green : AppTheme.accentGold,
                                trackColor: Color.white.opacity(0.2)
                            )
                            .frame(width: 32, height: 32)
                            
                            if item.isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(item.isCompleted ? "Selesai Dibaca" : "Ketuk untuk Menghitung")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Counter Badge
                        Text("\(item.currentCount) / \(item.targetCount)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 50)
                    .background(
                        item.isCompleted
                            ? LinearGradient(colors: [Color.green.opacity(0.85), Color.green], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [AppTheme.primaryForest, AppTheme.primarySage], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(
                        color: item.isCompleted ? Color.green.opacity(0.3) : AppTheme.primaryForest.opacity(0.25),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .modernCard(cornerRadius: 20, padding: 18)
    }
}

// Efek Tekan Tombol Tasbih yang Lembut
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
