import SwiftUI

// MARK: - Prayer Home View (Jadwal Sholat 100% Offline & Custom Foto)
struct PrayerHomeView: View {
    @ObservedObject var viewModel: PrayerViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingCityPicker = false
    @State private var showingHeaderCustomizer = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Utama dengan Custom Background Foto & Dimming Overlay
                    headerSection
                    
                    // Hero Countdown Card (Sholat Berikutnya)
                    nextPrayerHeroCard
                    
                    // Daftar Waktu Sholat 6 Waktu
                    prayerTimesSection
                    
                    // Offline Guarantee & Standar Info
                    offlineBadgeFooter
                }
                .padding(.bottom, 24)
            }
            .background(AppTheme.subtleBackground(for: colorScheme).ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCityPicker) {
                CityPickerSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingHeaderCustomizer) {
                HeaderCustomizerSheet(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Header Section dengan Custom Foto & Blur / Dimming
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Background: Foto Kustom Pengguna atau Gradien Elegan Default
            ZStack {
                if let customImage = viewModel.headerImage {
                    Image(uiImage: customImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    AppTheme.emeraldGradient()
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .blur(radius: viewModel.headerBlur)
            .overlay(
                // Dimming Overlay dengan slider pengguna agar teks selalu terbaca kontras
                Color.black.opacity(viewModel.headerDimming)
            )
            .clipped()
            
            // Konten Header Teks & Tombol Aksi
            VStack(alignment: .leading, spacing: 14) {
                // Baris Atas: Wilayah & Tombol Kustomisasi Foto
                HStack {
                    // Tombol Pemilih Kota
                    Button {
                        showingCityPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.isUsingGPS ? "location.fill" : "building.2.fill")
                                .font(.system(size: 13))
                            Text(viewModel.activeCity.name)
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial.opacity(0.4))
                        .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    // Tombol Kustom Foto Header
                    Button {
                        showingHeaderCustomizer = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 13))
                            Text("Ganti Foto")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial.opacity(0.4))
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Informasi Penanggalan Hijriah & Masehi
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.hijriDateText)
                        .font(.system(size: 19, weight: .bold, design: .serif))
                        .foregroundColor(AppTheme.softGold)
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    
                    Text(viewModel.gregorianDateText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                }
            }
            .padding(18)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    // MARK: - Next Prayer Hero Card
    private var nextPrayerHeroCard: some View {
        HStack(spacing: 18) {
            // Lingkaran Hitung Mundur
            ZStack {
                CircularProgressView(
                    progress: viewModel.progressToNextPrayer,
                    lineWidth: 6,
                    primaryColor: AppTheme.accentGold,
                    trackColor: Color.secondary.opacity(0.15)
                )
                .frame(width: 68, height: 68)
                
                Image(systemName: viewModel.nextPrayerType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(AppTheme.accentGold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Menuju \(viewModel.nextPrayerType.displayName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    let timeFormatter = DateFormatter()
                    let _ = timeFormatter.dateFormat = "HH:mm"
                    Text(timeFormatter.string(from: viewModel.nextPrayerTime))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primarySage)
                }
                
                Text("-\(viewModel.countdownString)")
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary(for: colorScheme))
            }
        }
        .modernCard(cornerRadius: 20, padding: 16)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Prayer Times Section
    private var prayerTimesSection: some View {
        VStack(spacing: 10) {
            ForEach(PrayerType.allCases) { prayer in
                let timeStr = viewModel.schedule?.formattedTime(for: prayer) ?? "--:--"
                let isCurrent = viewModel.currentPrayerType == prayer
                let isNext = viewModel.nextPrayerType == prayer
                let isNotif = viewModel.isNotificationEnabled(for: prayer)
                
                PrayerCardView(
                    prayer: prayer,
                    timeString: timeStr,
                    isCurrent: isCurrent,
                    isNext: isNext,
                    isNotificationEnabled: isNotif,
                    onToggleNotification: {
                        viewModel.toggleNotification(for: prayer)
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Offline Badge Footer
    private var offlineBadgeFooter: some View {
        HStack(spacing: 6) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 12))
            Text("100% Offline • Standar Kemenag RI (Subuh 20°, Isya 18°)")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.secondary)
        .padding(.vertical, 8)
    }
}
