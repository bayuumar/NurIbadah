import SwiftUI

// MARK: - Settings View (Pengaturan Aplikasi)
struct SettingsView: View {
    @ObservedObject var prayerViewModel: PrayerViewModel
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingCityPicker = false
    @State private var showingResetHeaderAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Lokasi & Wilayah
                Section {
                    Toggle("Deteksi Lokasi Otomatis (GPS)", isOn: $settings.useGPSLocation)
                        .onChange(of: settings.useGPSLocation) { enabled in
                            if enabled {
                                prayerViewModel.enableGPS()
                            }
                        }
                    
                    Button {
                        showingCityPicker = true
                    } label: {
                        HStack {
                            Text("Wilayah Sholat")
                                .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                            Spacer()
                            Text(prayerViewModel.activeCity.name)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Lokasi Sholat (Offline)")
                } footer: {
                    Text("Jadwal sholat dihitung secara offline berdasarkan koordinat lintang & bujur GPS atau daftar kota.")
                }
                
                // Section 2: Metode Hisab & Standar Kemenag
                Section {
                    Picker("Metode Perhitungan", selection: $settings.calculationMethod) {
                        ForEach(CalculationMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    
                    Stepper("Koreksi Waktu Sholat (Ihtiyat): \(settings.ihtiyatMinutes) Menit", value: $settings.ihtiyatMinutes, in: 0...5)
                    
                    Stepper("Koreksi Tanggal Hijriah: \(settings.hijriOffset >= 0 ? "+\(settings.hijriOffset)" : "\(settings.hijriOffset)") Hari", value: $settings.hijriOffset, in: -2...2)
                } header: {
                    Text("Hisab & Kalender")
                } footer: {
                    Text("Standar Kemenag RI menggunakan sudut Subuh 20° dan Isya 18° dengan pengaman waktu (ihtiyat) 2 menit.")
                }
                
                // Section 3: Notifikasi Waktu Sholat
                Section {
                    ForEach(PrayerType.allCases.filter { $0.isFardhu }) { prayer in
                        Toggle(prayer.displayName, isOn: Binding(
                            get: { settings.isNotificationEnabled(for: prayer) },
                            set: { _ in prayerViewModel.toggleNotification(for: prayer) }
                        ))
                    }
                } header: {
                    Text("Pengingat Waktu Sholat")
                } footer: {
                    Text("Pengingat sholat dijadwalkan secara lokal di perangkat tanpa menggunakan server internet.")
                }
                
                // Section 4: Kustomisasi Tampilan
                Section {
                    Picker("Tema Tampilan", selection: $settings.appTheme) {
                        Text("Otomatis (Sistem)").tag(0)
                        Text("Terang (Light)").tag(1)
                        Text("Gelap (Dark)").tag(2)
                    }
                    
                    if prayerViewModel.headerImage != nil {
                        Button(role: .destructive) {
                            showingResetHeaderAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "photo.badge.minus")
                                Text("Kembalikan Foto Header ke Standar")
                            }
                        }
                    }
                } header: {
                    Text("Tampilan")
                }
                
                // Section 5: Tentang & Privasi 100% Offline
                Section {
                    NavigationLink {
                        AboutAppView()
                    } label: {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(AppTheme.primarySage)
                            Text("Tentang NurIbadah & Jaminan Privasi")
                                .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                        }
                    }
                } header: {
                    Text("Informasi")
                }
            }
            .navigationTitle("Pengaturan")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCityPicker) {
                CityPickerSheetView(viewModel: prayerViewModel)
            }
            .alert("Reset Foto Header?", isPresented: $showingResetHeaderAlert) {
                Button("Batal", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    prayerViewModel.resetHeaderToDefault()
                }
            } message: {
                Text("Foto header kustom akan dihapus dan kembali ke tampilan gradien standar.")
            }
        }
    }
}
