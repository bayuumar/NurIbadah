import SwiftUI
import SwiftData

// MARK: - Detail View Catatan Muhasabah
struct MuhasabahDetailView: View {
    let note: MuhasabahNote
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingEditSheet: Bool = false
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Info: Kategori & Tanggal
                HStack {
                    MoodBadgeView(category: note.category, isSelected: true)
                    
                    Spacer()
                    
                    Text(note.formattedDate)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                // Judul Catatan
                Text(note.title)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                
                // Foto Lampiran Kustom jika ada
                if let photoData = note.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .padding(.vertical, 4)
                }
                
                Divider()
                
                // Isi Konten Refleksi
                Text(note.content)
                    .font(.system(size: 16))
                    .lineSpacing(6)
                    .foregroundColor(AppTheme.textPrimary(for: colorScheme))
            }
            .padding(20)
        }
        .background(AppTheme.subtleBackground(for: colorScheme).ignoresSafeArea())
        .navigationTitle("Detail Muhasabah")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditNoteView(noteToEdit: note)
        }
        .alert("Hapus Catatan?", isPresented: $showingDeleteAlert) {
            Button("Batal", role: .cancel) {}
            Button("Hapus", role: .destructive) {
                modelContext.delete(note)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("Catatan ini akan dihapus secara permanen dari perangkat Anda.")
        }
    }
}
