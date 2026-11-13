# NurIbadah (نور العبادة) - Pendamping Ibadah Harian 100% Offline

Aplikasi iOS modern berbasis **Swift** dan **SwiftUI** yang dirancang khusus untuk berjalan **100% OFFLINE** (tanpa koneksi internet sama sekali, berfungsi penuh dalam Mode Pesawat / *Airplane Mode*). Aplikasi ini menggabungkan **Jadwal Sholat Astronomis Kemenag RI**, **Dzikir Pagi, Sore & Harian dengan Tasbih Interaktif**, serta **Catatan Pribadi (Jurnal Muhasabah)** dengan fitur **Custom Foto dari Galeri iPhone**.

---

## Fitur Utama

### 1. Jadwal Sholat 100% Offline (Perhitungan Astronomis Lokal)
- **Tanpa API Eksternal:** Menghitung waktu Subuh, Terbit, Dzuhur, Ashar, Maghrib, dan Isya langsung di perangkat menggunakan rumus astronomis posisi matahari (*Solar Position Algorithm*).
- **Standar Kemenag RI:**
  - Sudut Subuh: **20°**
  - Sudut Isya: **18°**
  - Ashar: Madzhab Syafi'i (rasio bayangan 1.0)
  - Pengaman waktu (*Ihtiyat*): **+2 menit** (dapat diatur 0-5 menit di Pengaturan)
  - Pilihan metode alternatif: MWL, Egyptian General Authority, Umm al-Qura.
- **Deteksi Lokasi Offline:**
  - **GPS Otomatis:** Memanfaatkan hardware GPS perangkat (`CoreLocation`) secara offline tanpa butuh paket data/sinyal seluler.
  - **Katalog Kota Cadangan:** 30+ kota utama Indonesia di 3 zona waktu (WIB, WITA, WIT) lengkap dengan koordinat presisi jika GPS dinonaktifkan.
- **Konversi Tanggal Hijriah Lokal:** Menggunakan `Calendar(identifier: .islamicUmmAlQura)` dengan fitur koreksi hari (*hilal offset* ±2 hari).
- **Hitung Mundur (*Live Countdown*):** Tampilan *hero card* hitung mundur menuju waktu sholat berikutnya dengan cincin progres lingkaran (*circular progress*).
- **Notifikasi Lokal:** Pengingat azan/sholat dijadwalkan secara lokal di perangkat (`UserNotifications`) dengan tombol *toggle* pada tiap waktu sholat.

### 2. Kustomisasi Foto Header & Kontrol Kegelapan (*Dimming*)
- **Custom Foto Utama:** Pengguna dapat mengganti latar belakang *header* halaman jadwal sholat menggunakan foto pribadi dari galeri iPhone via `PhotosPicker`.
- **Slider Tingkat Kegelapan (*Dimming Overlay*):** Rentang 10% s/d 85% untuk memastikan teks jadwal sholat dan tanggal selalu terbaca jelas di atas foto apa pun.
- **Slider Efek Blur:** Rentang 0 s/d 15 pt untuk memberikan kesan kabur lembut yang elegan.
- **Tombol Reset:** Kembalikan foto latar ke gradien *Modern Islamic Emerald* kapan saja.

### 3. Dzikir Pagi, Sore & Harian (Tasbih Digital Interaktif)
- **Data Bundled Autentik:** Teks dzikir lengkap tersimpan di dalam bundle lokal (`DzikirData.json` dan kode Swift fallback):
  - **Dzikir Pagi:** Ayat Kursi, Al-Mu'awwidzat, Sayyidul Istighfar, Dzikir Perlindungan, Tasbih 100x, dsb.
  - **Dzikir Sore:** Ayat Kursi, Sayyidul Istighfar, A'uudzu bikalimatillah, dsb.
  - **Dzikir Harian:** Dzikir sesudah sholat fardhu (Istighfar, Tasbih 33x, Tahmid 33x, Takbir 33x, Tahlil) & doa sapu jagad.
- **Tipografi Arab Dinamis:** Huruf Arab berharakat jelas dengan pengaturan ukuran font (20 pt, 26 pt, 32 pt, 38 pt), transliterasi Latin miring, dan terjemahan bahasa Indonesia.
- **Tasbih Digital Bergetar (*Haptic Feedback*):**
  - Sentuhan tasbih memberikan umpan balik getaran ringan (`UIImpactFeedbackGenerator`).
  - Target tercapai memicu getaran sukses (`UINotificationFeedbackGenerator(.success)`).
  - Indikator progres lingkaran, tombol reset per dzikir, dan tombol reset seluruh kategori.
- **Mode Fokus Penuh Layar (*Focus Mode*):** Tombol tap tasbih raksasa untuk dzikir mendalam setelah sholat tanpa distraksi.

### 4. Catatan Pribadi (Jurnal Muhasabah) & Custom Foto Lampiran
- **Penyimpanan Aman SwiftData:** Catatan tersimpan di penyimpanan internal iPhone pengguna tanpa sinkronisasi cloud atau tracking pihak ketiga.
- **Fitur Lengkap (CRUD):** Tambah, baca detail, edit, dan hapus catatan refleksi atau target ibadah.
- **Label Kategori/Mood:** Syukur, Muhasabah, Doa, Harapan, dan Evaluasi Diri.
- **Lampiran Foto Kustom:** Integrasi `PhotosPicker` untuk melampirkan foto masjid, alam, atau catatan ibadah. Foto otomatis dikompresi efisien ke JPEG resolusi optimal (`ImageCompressor`) agar hemat memori.
- **Pencarian & Filter:** Cari catatan berdasarkan kata kunci atau pilih filter chip kategori.

---

## Arsitektur Proyek (MVVM + SwiftData)

```
NurIbadah/
├── NurIbadah.xcodeproj/            # File Proyek Xcode Siap Build & Run
│   ├── project.pbxproj
│   └── project.xcworkspace/
├── NurIbadah/
│   ├── App/
│   │   └── NurIbadahApp.swift      # Entry point @main, SwiftData ModelContainer setup
│   ├── Models/
│   │   ├── PrayerTime.swift        # Enum PrayerType, CalculationMethod, PrayerSchedule
│   │   ├── CityLocation.swift      # Model kota Indonesia & timezone offset
│   │   ├── DzikirItem.swift        # Model dzikir, kategori, & hitungan
│   │   ├── MuhasabahNote.swift     # @Model SwiftData untuk jurnal catatan
│   │   └── AppSettings.swift       # Pengaturan pengguna & persistensi lokal
│   ├── Services/
│   │   ├── PrayerCalculationService.swift # Rumus astronomis posisi matahari offline
│   │   ├── LocationManager.swift   # CoreLocation GPS offline reader
│   │   ├── NotificationService.swift # Local UserNotifications scheduler
│   │   ├── HijriDateService.swift  # Konverter kalender Ummul Qura offline
│   │   ├── ImageCompressor.swift   # Kompresi gambar efisien untuk galeri
│   │   └── DataLoader.swift        # JSON loader dengan in-code safe fallbacks
│   ├── ViewModels/
│   │   ├── PrayerViewModel.swift   # State jadwal sholat, countdown, header photo
│   │   └── DzikirViewModel.swift   # State tasbih, haptics, filter kategori
│   ├── Views/
│   │   ├── MainTabView.swift       # TabView utama navigasi bawah
│   │   ├── Components/
│   │   │   ├── CardBackgroundModifier.swift # Card styling rounded & border
│   │   │   ├── CircularProgressView.swift   # Cincin progres animasi
│   │   │   └── MoodBadgeView.swift          # Badge mood kategori warna-warni
│   │   ├── Prayer/
│   │   │   ├── PrayerHomeView.swift         # Layar jadwal sholat & custom header
│   │   │   ├── PrayerCardView.swift         # Kartu waktu sholat & toggle bel notif
│   │   │   ├── CityPickerSheetView.swift    # Sheet pencarian kota Indonesia
│   │   │   └── HeaderCustomizerSheet.swift  # Sheet ganti foto, slider dimming & blur
│   │   ├── Dzikir/
│   │   │   ├── DzikirHomeView.swift         # Layar dzikir pagi/sore/harian
│   │   │   ├── DzikirCardView.swift         # Kartu dzikir & tombol tasbih
│   │   │   └── DzikirFocusModalView.swift   # Layar fokus tasbih raksasa
│   │   ├── Muhasabah/
│   │   │   ├── MuhasabahHomeView.swift      # Layar daftar catatan & filter chip
│   │   │   ├── MuhasabahDetailView.swift    # Layar baca catatan & foto penuh
│   │   │   └── AddEditNoteView.swift        # Sheet tulis/edit catatan + PhotosPicker
│   │   └── Settings/
│   │       ├── SettingsView.swift           # Pengaturan hisab, tema, & notifikasi
│   │       └── AboutAppView.swift           # Info privasi 100% offline
│   ├── Theme/
│   │   └── AppTheme.swift          # Palet warna Modern Islamic Minimalist
│   ├── Resources/
│   │   ├── IndonesianCities.json   # 30+ Kota Indonesia (WIB, WITA, WIT)
│   │   └── DzikirData.json         # Kumpulan teks dzikir autentik & sanad
│   ├── Assets.xcassets/            # AppIcon, AccentColor, PrimaryEmerald
│   └── Info.plist                  # Izin Lokasi & Galeri Foto
└── README.md
```

---

## Cara Menjalankan di Mac / Xcode

1. **Buka Proyek:**
   - Salin folder `NurIbadah` ke komputer Mac.
   - Klik ganda pada file `NurIbadah.xcodeproj` untuk membukanya di **Xcode 15+**.
2. **Pilih Simulator / Perangkat Nyata:**
   - Pilih target perangkat, misalnya: **iPhone 15 Pro** atau **iPhone 16 Pro**.
3. **Build & Run:**
   - Tekan tombol **Play / Run** (`⌘ + R`).
   - Aplikasi akan langsung terkompilasi dan berjalan mulus tanpa error.
4. **Uji Mode Pesawat (*Airplane Mode*):**
   - Matikan koneksi Wi-Fi dan Cellular pada Simulator atau iPhone Anda.
   - Semua fitur (Jadwal Sholat, Dzikir, Tasbih, Catatan Muhasabah, dan Custom Foto) tetap berfungsi 100% sempurna!

---

## Spesifikasi Teknis & Persyaratan Sistem
- **Sistem Operasi:** iOS 17.0+
- **Bahasa Pemrograman:** Swift 5.9 / Swift 6.0
- **UI Framework:** SwiftUI
- **Penyimpanan Data:** SwiftData (Local Schema)
- **Komponen Sistem:**
  - `CoreLocation` (Offline GPS positioning)
  - `UserNotifications` (Local device alert scheduling)
  - `PhotosUI` (`PhotosPicker` untuk header & catatan)
  - `UIKit` (`UIImpactFeedbackGenerator`, `UIGraphicsImageRenderer`)
- **Dependensi Eksternal:** **0 (Nol)** — Murni Swift & Apple Foundation standard library.
