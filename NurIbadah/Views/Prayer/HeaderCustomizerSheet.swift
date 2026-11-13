import SwiftUI
import PhotosUI

// MARK: - Header Customization Sheet with PhotosPicker
struct HeaderCustomizerSheet: View {
    @ObservedObject var viewModel: PrayerViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var tempImage: UIImage? = nil
    @State private var tempDimming: Double = 0.45
    @State private var tempBlur: Double = 0.0
    @State private var isProcessingPhoto: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview Banner
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pratinjau Tampilan Header")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            // Background Image or Default Gradient
                            if let img = tempImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                AppTheme.emeraldGradient()
                            }
                        }
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .blur(radius: tempBlur)
                        .overlay(
                            Color.black.opacity(tempDimming)
                        )
                        .overlay(
                            VStack(spacing: 6) {
                                Text("15 Sya'ban 1448 H")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("Dzuhur 11:58")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Menuju Ashar • 02:45:10")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.softGold)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    
                    // PhotosPicker Action
                    VStack(spacing: 12) {
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                    .font(.headline)
                                Text(tempImage != nil ? "Ganti Foto dari Galeri" : "Pilih Foto Latar dari Galeri")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.primaryForest)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(isProcessingPhoto)
                        
                        if tempImage != nil {
                            Button(role: .destructive) {
                                withAnimation {
                                    tempImage = nil
                                    tempDimming = 0.45
                                    tempBlur = 0.0
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Kembalikan ke Latar Standar")
                                }
                                .font(.subheadline)
                                .foregroundColor(.red)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sliders Section
                    VStack(alignment: .leading, spacing: 20) {
                        // Dimming Slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Tingkat Kegelapan (Dimming)", systemImage: "circle.lefthalf.filled")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(tempDimming * 100))%")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: $tempDimming, in: 0.10...0.85, step: 0.05)
                                .tint(AppTheme.accentGold)
                            
                            Text("Gelapkan latar belakang agar teks jadwal sholat selalu kontras dan mudah dibaca.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Blur Slider
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("Efek Blur (Kabur)", systemImage: "aqi.medium")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("\(Int(tempBlur)) pt")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Slider(value: $tempBlur, in: 0.0...15.0, step: 1.0)
                                .tint(AppTheme.accentGold)
                            
                            Text("Berikan efek kabur lembut untuk meminimalisir distraksi visual foto.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .modernCard()
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Kustom Foto Header")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.accentGold)
                }
            }
            .onAppear {
                self.tempImage = viewModel.headerImage
                self.tempDimming = viewModel.headerDimming
                self.tempBlur = viewModel.headerBlur
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let item = newItem else { return }
                    isProcessingPhoto = true
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            self.tempImage = image
                            self.isProcessingPhoto = false
                        }
                    } else {
                        await MainActor.run {
                            self.isProcessingPhoto = false
                        }
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        if let img = tempImage {
            viewModel.setCustomHeaderPhoto(image: img)
        } else {
            viewModel.resetHeaderToDefault()
        }
        viewModel.setHeaderDimming(tempDimming)
        viewModel.setHeaderBlur(tempBlur)
    }
}
