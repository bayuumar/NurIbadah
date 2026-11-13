import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Add or Edit Muhasabah Note Sheet
struct AddEditNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Nil jika membuat baru, terisi jika mode edit
    var noteToEdit: MuhasabahNote?
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: MuhasabahCategory = .muhasabah
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @State private var isProcessingPhoto: Bool = false
    
    var isEditMode: Bool {
        noteToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Pilihan Mood / Kategori
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategori / Mood Refleksi")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(MuhasabahCategory.allCases.filter { $0 != .all }) { category in
                                    Button {
                                        selectedCategory = category
                                    } label: {
                                        MoodBadgeView(
                                            category: category,
                                            isSelected: selectedCategory == category
                                        )
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Input Judul
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Judul Catatan")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("Misal: Refleksi Sholat Tahajjud, Syukur Nikmat Sehat...", text: $title)
                            .font(.system(size: 16, weight: .semibold))
                            .padding(14)
                            .background(AppTheme.cardBackground(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(AppTheme.cardBorder(for: colorScheme), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Lampiran Foto Kustom (PhotosPicker)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Lampiran Foto")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if photoData != nil {
                                Button(role: .destructive) {
                                    withAnimation {
                                        photoData = nil
                                        selectedPhotoItem = nil
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "trash")
                                        Text("Hapus Foto")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                            }
                        }
                        
                        if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                            // Pratinjau Foto Terpilih
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                            }
                        } else {
                            // Tombol Pilih Foto
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 20))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Tambah Foto Refleksi dari Galeri")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Dokumentasikan masjid, alam, atau momen ibadah Anda (Offline)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .background(AppTheme.cardBackground(for: colorScheme))
                                .foregroundColor(AppTheme.primarySage)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundColor(AppTheme.primarySage.opacity(0.4))
                                )
                            }
                            .disabled(isProcessingPhoto)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Input Isi Catatan
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Isi Refleksi / Muhasabah")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ZStack(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Tuliskan apa yang Anda syukuri, evaluasi ibadah hari ini, atau permohonan doa mendalam...")
                                    .foregroundColor(Color.secondary.opacity(0.6))
                                    .padding(.top, 16)
                                    .padding(.leading, 14)
                                    .font(.system(size: 15))
                            }
                            
                            TextEditor(text: $content)
                                .font(.system(size: 15))
                                .frame(minHeight: 180)
                                .padding(10)
                                .background(Color.clear)
                        }
                        .background(AppTheme.cardBackground(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AppTheme.cardBorder(for: colorScheme), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(isEditMode ? "Edit Catatan" : "Catatan Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan") {
                        saveNote()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.accentGold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let note = noteToEdit {
                    self.title = note.title
                    self.content = note.content
                    self.selectedCategory = note.category
                    self.photoData = note.photoData
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    guard let item = newItem else { return }
                    isProcessingPhoto = true
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data),
                       let compressed = ImageCompressor.compress(image: image, maxDimension: 1280, quality: 0.75) {
                        await MainActor.run {
                            self.photoData = compressed
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
    
    private func saveNote() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        if let note = noteToEdit {
            note.title = trimmedTitle
            note.content = content
            note.categoryMood = selectedCategory.rawValue
            note.photoData = photoData
            note.updatedAt = Date()
        } else {
            let newNote = MuhasabahNote(
                title: trimmedTitle,
                content: content,
                categoryMood: selectedCategory,
                photoData: photoData,
                createdAt: Date()
            )
            modelContext.insert(newNote)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
