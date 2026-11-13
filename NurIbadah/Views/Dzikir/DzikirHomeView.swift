import SwiftUI

// MARK: - Dzikir Home View
struct DzikirHomeView: View {
    @ObservedObject var viewModel: DzikirViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingResetAlert: Bool = false
    @State private var itemToFocus: DzikirItem? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Category Segmented Picker (Pagi, Sore, Harian)
                    categoryPickerSection
                    
                    // Banner Progres Kategori
                    categoryProgressBanner
                    
                    // Controls: Font Size Slider & Reset All Button
                    controlsBar
                    
                    // Daftar Kartu Dzikir
                    dzikirListSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(AppTheme.subtleBackground(for: colorScheme).ignoresSafeArea())
            .navigationTitle("Dzikir & Doa")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $itemToFocus) { item in
                DzikirFocusModalView(viewModel: viewModel, item: item)
            }
            .alert("Reset Semua Dzikir?", isPresented: $showingResetAlert) {
                Button("Batal", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetAllInCategory()
                }
            } message: {
                Text("Hitungan semua dzikir di kategori \(viewModel.selectedCategory.title) akan dikembalikan ke 0.")
            }
        }
    }
    
    // MARK: - Category Segmented Picker
    private var categoryPickerSection: some View {
        HStack(spacing: 8) {
            ForEach(DzikirCategory.allCases) { category in
                let isSelected = viewModel.selectedCategory == category
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedCategory = category
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: category.iconName)
                            .font(.system(size: 13, weight: .semibold))
                        Text(category.title)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isSelected ? AppTheme.primaryForest : Color.secondary.opacity(0.1))
                    .foregroundColor(isSelected ? .white : AppTheme.textPrimary(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
    
    // MARK: - Banner Progres Kategori
    private var categoryProgressBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.selectedCategory.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    Text(viewModel.selectedCategory.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Progress Counter
                Text("\(viewModel.completedCountInCategory)/\(viewModel.totalCountInCategory) Selesai")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(viewModel.categoryProgressFraction == 1.0 ? Color.green.opacity(0.18) : AppTheme.primarySage.opacity(0.15))
                    .foregroundColor(viewModel.categoryProgressFraction == 1.0 ? Color.green : AppTheme.primarySage)
                    .clipShape(Capsule())
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(viewModel.categoryProgressFraction == 1.0 ? Color.green : AppTheme.accentGold)
                        .frame(width: geo.size.width * CGFloat(viewModel.categoryProgressFraction), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.categoryProgressFraction)
                }
            }
            .frame(height: 6)
        }
        .modernCard(cornerRadius: 16, padding: 14)
    }
    
    // MARK: - Controls Bar (Font Size & Reset All)
    private var controlsBar: some View {
        HStack {
            // Ukuran Font Arab Menu
            Menu {
                Button("Kecil (20 pt)") { viewModel.setArabicFontSize(20) }
                Button("Sedang (26 pt)") { viewModel.setArabicFontSize(26) }
                Button("Besar (32 pt)") { viewModel.setArabicFontSize(32) }
                Button("Sangat Besar (38 pt)") { viewModel.setArabicFontSize(38) }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "textformat.size")
                        .font(.system(size: 13))
                    Text("Ukuran Arab: \(Int(viewModel.arabicFontSize)) pt")
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.1))
                .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // Tombol Reset Semua
            Button {
                showingResetAlert = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12))
                    Text("Reset Kategori")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.red.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.08))
                .clipShape(Capsule())
            }
            .disabled(viewModel.completedCountInCategory == 0)
        }
    }
    
    // MARK: - Daftar Kartu Dzikir
    private var dzikirListSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.currentCategoryItems) { item in
                DzikirCardView(
                    item: item,
                    arabicFontSize: viewModel.arabicFontSize,
                    onIncrement: {
                        viewModel.incrementCount(for: item)
                    },
                    onReset: {
                        viewModel.resetCount(for: item)
                    },
                    onOpenFocus: {
                        itemToFocus = item
                    }
                )
            }
        }
    }
}
