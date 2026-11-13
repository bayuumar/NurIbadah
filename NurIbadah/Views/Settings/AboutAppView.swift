import SwiftUI

// MARK: - About App & Privacy Info View
struct AboutAppView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Brand Icon
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryForest)
                            .frame(width: 88, height: 88)
                            .shadow(color: AppTheme.primaryForest.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 42))
                            .foregroundColor(AppTheme.softGold)
                    }
                    
                    VStack(spacing: 4) {
                        Text("NurIbadah")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                        
                        Text("Pendamping Ibadah Harian • Versi 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 16)
                
                // Card 1: 100% Offline Guarantee
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "wifi.slash")
                            .font(.title2)
                            .foregroundColor(AppTheme.primarySage)
                        Text("Jaminan 100% Offline")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    }
                    
                    Text("Aplikasi ini dirancang sepenuhnya untuk bekerja tanpa koneksi internet sama sekali. Seluruh data jadwal sholat dihitung langsung di ponsel Anda menggunakan algoritma posisi matahari astronomis, bacaan dzikir tersimpan di dalam aplikasi, dan catatan muhasabah Anda tersimpan aman secara lokal di SwiftData.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary(for: colorScheme))
                        .lineSpacing(4)
                }
                .modernCard()
                
                // Card 2: Standar Kemenag RI
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "sun.max.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.accentGold)
                        Text("Standar Hisab Kemenag RI")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    }
                    
                    Text("Mengikuti standar resmi Kementerian Agama Republik Indonesia:\n• Sudut Depresi Subuh: 20°\n• Sudut Depresi Isya: 18°\n• Ashar: Madzhab Syafi'i (Rasio Bayangan 1.0)\n• Waktu Pengaman (Ihtiyat): +2 Menit\n• Konversi Kalender Hijriah Ummul Qura")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary(for: colorScheme))
                        .lineSpacing(4)
                }
                .modernCard()
                
                // Card 3: Keamanan & Privasi
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("Privasi & Keamanan Penuh")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                    }
                    
                    Text("Tidak ada pelacak (analytics), tidak ada iklan, dan tidak ada pengiriman data ke server mana pun. Foto kustom dan tulisan muhasabah Anda adalah rahasia pribadi Anda sepenuhnya.")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary(for: colorScheme))
                        .lineSpacing(4)
                }
                .modernCard()
                
                // Footer
                Text("Dibuat dengan cinta untuk umat Islam Indonesia.\nSemoga menjadi amal jariyah yang bermanfaat.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
        }
        .background(AppTheme.subtleBackground(for: colorScheme).ignoresSafeArea())
        .navigationTitle("Tentang NurIbadah")
        .navigationBarTitleDisplayMode(.inline)
    }
}
