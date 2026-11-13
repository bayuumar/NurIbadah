import Foundation
import SwiftUI
import CoreLocation
import Combine

// MARK: - Prayer View Model
@MainActor
final class PrayerViewModel: ObservableObject {
    @Published var schedule: PrayerSchedule?
    @Published var nextPrayerType: PrayerType = .subuh
    @Published var nextPrayerTime: Date = Date()
    @Published var currentPrayerType: PrayerType? = nil
    @Published var countdownString: String = "--:--:--"
    @Published var progressToNextPrayer: Double = 0.0
    
    @Published var availableCities: [CityLocation] = []
    @Published var activeCity: CityLocation = CityLocation.defaultCity
    @Published var isUsingGPS: Bool = true
    @Published var hijriDateText: String = ""
    @Published var gregorianDateText: String = ""
    
    // Header Customization State (PhotosPicker)
    @Published var headerImage: UIImage? = nil
    @Published var headerDimming: Double = 0.45
    @Published var headerBlur: Double = 0.0
    
    private let settings = AppSettings.shared
    private let locationManager = LocationManager.shared
    private let calculationService = PrayerCalculationService.shared
    private let hijriService = HijriDateService.shared
    private let notificationService = NotificationService.shared
    private let dataLoader = DataLoader.shared
    
    private var timer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.availableCities = dataLoader.loadCities()
        self.isUsingGPS = settings.useGPSLocation
        self.headerDimming = settings.headerDimming
        self.headerBlur = settings.headerBlur
        
        if let photoData = settings.headerPhotoData {
            self.headerImage = UIImage(data: photoData)
        }
        
        setupActiveCity()
        recalculateSchedule()
        startCountdownTimer()
        observeChanges()
    }
    
    private func setupActiveCity() {
        if let matched = availableCities.first(where: { $0.id == settings.selectedCityId }) {
            self.activeCity = matched
        } else {
            self.activeCity = CityLocation.defaultCity
        }
    }
    
    private func observeChanges() {
        // Pantau update GPS
        locationManager.$lastLocation
            .sink { [weak self] location in
                guard let self = self, self.isUsingGPS, let location = location else { return }
                self.matchNearestCity(for: location)
                self.recalculateSchedule()
            }
            .store(in: &cancellables)
        
        // Pantau update dari AppSettings
        settings.$headerDimming
            .sink { [weak self] dimming in self?.headerDimming = dimming }
            .store(in: &cancellables)
            
        settings.$headerBlur
            .sink { [weak self] blur in self?.headerBlur = blur }
            .store(in: &cancellables)
            
        settings.$calculationMethod
            .sink { [weak self] _ in self?.recalculateSchedule() }
            .store(in: &cancellables)
            
        settings.$ihtiyatMinutes
            .sink { [weak self] _ in self?.recalculateSchedule() }
            .store(in: &cancellables)
            
        settings.$hijriOffset
            .sink { [weak self] _ in self?.updateDateTexts() }
            .store(in: &cancellables)
    }
    
    /// Mencocokkan kota terdekat berdasarkan koordinat GPS
    private func matchNearestCity(for location: CLLocation) {
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude
        var closestCity = activeCity
        
        for city in availableCities {
            let cityLoc = CLLocation(latitude: city.latitude, longitude: city.longitude)
            let distance = location.distance(from: cityLoc)
            if distance < minDistance {
                minDistance = distance
                closestCity = city
            }
        }
        
        // Buat objek kota dinamis dengan koordinat GPS aktual
        self.activeCity = CityLocation(
            id: closestCity.id,
            name: closestCity.name,
            province: closestCity.province,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timezoneOffsetHours: closestCity.timezoneOffsetHours,
            timezoneName: closestCity.timezoneName
        )
    }
    
    /// Menghitung ulang jadwal sholat
    func recalculateSchedule() {
        let now = Date()
        updateDateTexts()
        
        let schedule = calculationService.calculateSchedule(
            for: now,
            latitude: activeCity.latitude,
            longitude: activeCity.longitude,
            timezoneOffsetHours: activeCity.timezoneOffsetHours,
            method: settings.calculationMethod,
            ihtiyatMinutes: settings.ihtiyatMinutes
        )
        self.schedule = schedule
        
        updateCountdown()
        rescheduleNotifications()
    }
    
    /// Memperbarui teks tanggal Hijriah dan Masehi
    func updateDateTexts() {
        let now = Date()
        self.hijriDateText = hijriService.formatHijriDate(from: now, dayOffset: settings.hijriOffset)
        self.gregorianDateText = hijriService.formatGregorianDate(from: now)
    }
    
    /// Timer hitung mundur waktu sholat setiap detik
    private func startCountdownTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCountdown()
            }
    }
    
    private func updateCountdown() {
        guard let schedule = schedule else { return }
        let now = Date()
        let result = schedule.currentAndNextPrayer(at: now)
        
        self.currentPrayerType = result.current
        self.nextPrayerType = result.next
        self.nextPrayerTime = result.nextTime
        
        let seconds = Int(result.remainingSeconds)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        self.countdownString = String(format: "%02d:%02d:%02d", hours, minutes, secs)
        
        // Hitung progres lingkaran countdown
        if let previousTime = schedule.time(for: result.current ?? .isya) {
            let totalInterval = result.nextTime.timeIntervalSince(previousTime)
            if totalInterval > 0 {
                let elapsed = now.timeIntervalSince(previousTime)
                self.progressToNextPrayer = min(1.0, max(0.0, elapsed / totalInterval))
            }
        }
    }
    
    /// Pilih kota manual
    func selectCity(_ city: CityLocation) {
        self.isUsingGPS = false
        settings.useGPSLocation = false
        settings.selectedCityId = city.id
        self.activeCity = city
        locationManager.stopUpdating()
        recalculateSchedule()
    }
    
    /// Beralih ke GPS
    func enableGPS() {
        self.isUsingGPS = true
        settings.useGPSLocation = true
        locationManager.startUpdating()
        if let last = locationManager.lastLocation {
            matchNearestCity(for: last)
        }
        recalculateSchedule()
    }
    
    /// Atur foto kustom header dari galeri
    func setCustomHeaderPhoto(image: UIImage?) {
        self.headerImage = image
        if let image = image,
           let compressed = ImageCompressor.compress(image: image, maxDimension: 1600, quality: 0.8) {
            settings.headerPhotoData = compressed
        } else {
            settings.headerPhotoData = nil
        }
    }
    
    /// Update tingkat kegelapan overlay (0.1 - 0.85)
    func setHeaderDimming(_ level: Double) {
        let clamped = min(0.85, max(0.1, level))
        self.headerDimming = clamped
        settings.headerDimming = clamped
    }
    
    /// Update tingkat blur header (0 - 15)
    func setHeaderBlur(_ radius: Double) {
        let clamped = min(15.0, max(0.0, radius))
        self.headerBlur = clamped
        settings.headerBlur = clamped
    }
    
    /// Reset header ke latar default
    func resetHeaderToDefault() {
        self.headerImage = nil
        self.headerDimming = 0.45
        self.headerBlur = 0.0
        settings.resetHeaderToDefault()
    }
    
    /// Toggle notifikasi untuk sholat tertentu
    func toggleNotification(for prayer: PrayerType) {
        settings.toggleNotification(for: prayer)
        rescheduleNotifications()
    }
    
    func isNotificationEnabled(for prayer: PrayerType) -> Bool {
        settings.isNotificationEnabled(for: prayer)
    }
    
    private func rescheduleNotifications() {
        guard let schedule = schedule else { return }
        var enabledMap: [PrayerType: Bool] = [:]
        for prayer in PrayerType.allCases {
            enabledMap[prayer] = settings.isNotificationEnabled(for: prayer)
        }
        notificationService.schedulePrayerNotifications(
            schedule: schedule,
            cityName: activeCity.name,
            enabledPrayers: enabledMap
        )
    }
}
