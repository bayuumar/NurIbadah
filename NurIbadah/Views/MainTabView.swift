import SwiftUI

// MARK: - Main Root Tab View
struct MainTabView: View {
    @StateObject private var prayerViewModel = PrayerViewModel()
    @StateObject private var dzikirViewModel = DzikirViewModel()
    @ObservedObject private var settings = AppSettings.shared
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Jadwal Sholat
            PrayerHomeView(viewModel: prayerViewModel)
                .tabItem {
                    Label("Sholat", systemImage: "clock.fill")
                }
                .tag(0)
            
            // Tab 2: Dzikir Pagi, Sore & Harian
            DzikirHomeView(viewModel: dzikirViewModel)
                .tabItem {
                    Label("Dzikir", systemImage: "hands.sparkles.fill")
                }
                .tag(1)
            
            // Tab 3: Catatan Pribadi (Jurnal Muhasabah)
            MuhasabahHomeView()
                .tabItem {
                    Label("Catatan", systemImage: "book.closed.fill")
                }
                .tag(2)
            
            // Tab 4: Pengaturan
            SettingsView(prayerViewModel: prayerViewModel)
                .tabItem {
                    Label("Pengaturan", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.primaryForest)
        .preferredColorScheme(colorSchemeForTheme(settings.appTheme))
        .onAppear {
            // Minta izin notifikasi lokal saat pertama kali aplikasi dibuka
            NotificationService.shared.requestAuthorization { _ in }
        }
    }
    
    private func colorSchemeForTheme(_ theme: Int) -> ColorScheme? {
        switch theme {
        case 1: return .light
        case 2: return .dark
        default: return nil // Otomatis sistem
        }
    }
}
