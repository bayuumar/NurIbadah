import SwiftUI
import SwiftData

// MARK: - Muhasabah Home View (Jurnal Pribadi Offline dengan Custom Foto)
struct MuhasabahHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @Query(sort: \MuhasabahNote.createdAt, order: .reverse) private var notes: [MuhasabahNote]
    
    @State private var searchText: String = ""
    @State private var selectedFilter: MuhasabahCategory = .all
    @State private var showingAddNoteSheet: Bool = false
    
    var filteredNotes: [MuhasabahNote] {
        notes.filter { note in
            let matchesCategory = (selectedFilter == .all) || (note.category == selectedFilter)
            let matchesSearch = searchText.isEmpty ||
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Filter Kategori Chips
                        filterChipsSection
                        
                        if filteredNotes.isEmpty {
                            emptyStateView
                                .padding(.top, 40)
                        } else {
                            // Daftar Kartu Catatan
                            LazyVStack(spacing: 14) {
                                ForEach(filteredNotes) { note in
                                    NavigationLink {
                                        MuhasabahDetailView(note: note)
                                    } label: {
                                        noteCard(for: note)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 70) // Beri ruang untuk floating button
                }
                
                // Floating Action Button Tambah Catatan
                Button {
                    showingAddNoteSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                        Text("Catatan Baru")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .background(AppTheme.primaryForest)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: AppTheme.primaryForest.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .background(AppTheme.subtleBackground(for: colorScheme).ignoresSafeArea())
            .navigationTitle("Catatan Muhasabah")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Cari catatan muhasabah...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNoteSheet = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(AppTheme.primarySage)
                    }
                }
            }
            .sheet(isPresented: $showingAddNoteSheet) {
                AddEditNoteView()
            }
        }
    }
    
    // MARK: - Filter Chips
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MuhasabahCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = category
                        }
                    } label: {
                        MoodBadgeView(
                            category: category,
                            isSelected: selectedFilter == category
                        )
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Note Card View
    private func noteCard(for note: MuhasabahNote) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                // Kategori & Tanggal
                HStack {
                    MoodBadgeView(category: note.category)
                    Spacer()
                    Text(note.shortDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Judul
                Text(note.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    .lineLimit(1)
                
                // Ringkasan Isi
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondary(for: colorScheme))
                        .lineLimit(2)
                        .lineSpacing(2)
                }
            }
            
            // Mini Thumbnail Foto jika dilampirkan
            if let photoData = note.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.cardBorder(for: colorScheme), lineWidth: 1)
                    )
            }
        }
        .modernCard(cornerRadius: 18, padding: 14)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 52))
                .foregroundColor(AppTheme.primarySage.opacity(0.6))
            
            VStack(spacing: 6) {
                Text(notes.isEmpty ? "Belum Ada Catatan" : "Tidak Ada Catatan yang Cocok")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                
                Text(notes.isEmpty
                    ? "Tulis refleksi harian, ungkapan rasa syukur, doa, atau evaluasi ibadah Anda dengan aman secara offline."
                    : "Coba ubah kata kunci pencarian atau filter kategori di atas.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if notes.isEmpty {
                Button {
                    showingAddNoteSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Tulis Catatan Pertama")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(AppTheme.primaryForest)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
    }
}
