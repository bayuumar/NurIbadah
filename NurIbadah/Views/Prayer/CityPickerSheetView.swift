import SwiftUI

// MARK: - Indonesian City Selector Sheet (100% Offline)
struct CityPickerSheetView: View {
    @ObservedObject var viewModel: PrayerViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText: String = ""
    
    var filteredCities: [CityLocation] {
        if searchText.isEmpty {
            return viewModel.availableCities
        } else {
            return viewModel.availableCities.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.province.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Section GPS
                Section {
                    Button {
                        viewModel.enableGPS()
                        dismiss()
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primarySage.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "location.fill")
                                    .foregroundColor(AppTheme.primarySage)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gunakan Lokasi GPS Otomatis")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                                Text("Deteksi koordinat lintang & bujur langsung dari GPS perangkat (Offline)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.isUsingGPS {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.primarySage)
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Deteksi Otomatis")
                }
                
                // Section Kota Cadangan Offline
                Section {
                    ForEach(filteredCities) { city in
                        Button {
                            viewModel.selectCity(city)
                            dismiss()
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(city.name)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.textPrimary(for: colorScheme))
                                    
                                    Text(city.province)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text(city.timezoneName)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(Capsule())
                                
                                if !viewModel.isUsingGPS && viewModel.activeCity.id == city.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.primarySage)
                                        .font(.title3)
                                        .padding(.leading, 4)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } header: {
                    Text("Daftar Kota Indonesia (\(viewModel.availableCities.count) Wilayah Offline)")
                }
            }
            .searchable(text: $searchText, prompt: "Cari nama kota atau provinsi...")
            .navigationTitle("Pilih Wilayah Sholat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
}
