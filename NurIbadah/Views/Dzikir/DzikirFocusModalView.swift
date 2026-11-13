import SwiftUI

// MARK: - Fullscreen Focused Tasbih Modal
struct DzikirFocusModalView: View {
    @ObservedObject var viewModel: DzikirViewModel
    let item: DzikirItem
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var currentItem: DzikirItem {
        viewModel.allItems.first(where: { $0.id == item.id }) ?? item
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Info Header
                VStack(spacing: 6) {
                    Text(currentItem.category.title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundColor(AppTheme.accentGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentGold.opacity(0.12))
                        .clipShape(Capsule())
                    
                    Text(currentItem.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    
                    Text(currentItem.source)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                // Teks Arab Ringkas
                ScrollView {
                    VStack(spacing: 12) {
                        Text(currentItem.arabicText)
                            .font(.system(size: viewModel.arabicFontSize, weight: .regular, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .padding(.horizontal, 20)
                            .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                        
                        if !currentItem.translation.isEmpty {
                            Text(currentItem.translation)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                    }
                }
                .frame(maxHeight: 200)
                
                Spacer()
                
                // Area Tombol Tasbih Raksasa
                ZStack {
                    // Lingkaran Progres Luar
                    CircularProgressView(
                        progress: currentItem.progressFraction,
                        lineWidth: 12,
                        primaryColor: currentItem.isCompleted ? Color.green : AppTheme.accentGold,
                        trackColor: Color.secondary.opacity(0.12)
                    )
                    .frame(width: 220, height: 220)
                    
                    // Tombol Tap
                    Button {
                        viewModel.incrementCount(for: currentItem)
                    } label: {
                        Circle()
                            .fill(
                                currentItem.isCompleted
                                    ? LinearGradient(colors: [Color.green.opacity(0.85), Color.green], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [AppTheme.primaryForest, AppTheme.primarySage], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 190, height: 190)
                            .shadow(
                                color: currentItem.isCompleted ? Color.green.opacity(0.3) : AppTheme.primaryForest.opacity(0.3),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                            .overlay(
                                VStack(spacing: 4) {
                                    if currentItem.isCompleted {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        Text("Selesai")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    } else {
                                        Text("\(currentItem.currentCount)")
                                            .font(.system(size: 54, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("dari \(currentItem.targetCount)")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Text("Ketuk")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .textCase(.uppercase)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.white.opacity(0.2))
                                            .foregroundColor(.white)
                                            .clipShape(Capsule())
                                            .padding(.top, 4)
                                    }
                                }
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Spacer()
                
                // Tombol Reset Bawah
                HStack {
                    Button {
                        viewModel.resetCount(for: currentItem)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Hitungan")
                        }
                        .font(.subheadline)
                        .foregroundColor(.red.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    .disabled(currentItem.currentCount == 0)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Mode Fokus Dzikir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Selesai") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentGold)
                }
            }
        }
    }
}
