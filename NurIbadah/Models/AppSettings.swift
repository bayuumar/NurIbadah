import Foundation
import SwiftUI

// MARK: - App Settings & Preferences
final class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    // Keys for UserDefaults
    private enum Keys {
        static let headerPhotoData = "app.headerPhotoData"
        static let headerDimming = "app.headerDimming"
        static let headerBlur = "app.headerBlur"
        static let useGPSLocation = "app.useGPSLocation"
        static let selectedCityId = "app.selectedCityId"
        static let calculationMethod = "app.calculationMethod"
        static let ihtiyatMinutes = "app.ihtiyatMinutes"
        static let hijriOffset = "app.hijriOffset"
        static let arabicFontSize = "app.arabicFontSize"
        static let prayerNotifications = "app.prayerNotifications"
        static let appTheme = "app.theme"
    }
    
    // Header Customization (Requirements 1 & 2)
    @Published var headerPhotoData: Data? {
        didSet { UserDefaults.standard.set(headerPhotoData, forKey: Keys.headerPhotoData) }
    }
    
    @Published var headerDimming: Double {
        didSet { UserDefaults.standard.set(headerDimming, forKey: Keys.headerDimming) }
    }
    
    @Published var headerBlur: Double {
        didSet { UserDefaults.standard.set(headerBlur, forKey: Keys.headerBlur) }
    }
    
    // Location Preference
    @Published var useGPSLocation: Bool {
        didSet { UserDefaults.standard.set(useGPSLocation, forKey: Keys.useGPSLocation) }
    }
    
    @Published var selectedCityId: String {
        didSet { UserDefaults.standard.set(selectedCityId, forKey: Keys.selectedCityId) }
    }
    
    // Prayer Calculation
    @Published var calculationMethod: CalculationMethod {
        didSet { UserDefaults.standard.set(calculationMethod.rawValue, forKey: Keys.calculationMethod) }
    }
    
    @Published var ihtiyatMinutes: Int {
        didSet { UserDefaults.standard.set(ihtiyatMinutes, forKey: Keys.ihtiyatMinutes) }
    }
    
    @Published var hijriOffset: Int {
        didSet { UserDefaults.standard.set(hijriOffset, forKey: Keys.hijriOffset) }
    }
    
    // Dzikir Typography
    @Published var arabicFontSize: Double {
        didSet { UserDefaults.standard.set(arabicFontSize, forKey: Keys.arabicFontSize) }
    }
    
    // Notifications per prayer
    @Published var prayerNotifications: [String: Bool] {
        didSet { UserDefaults.standard.set(prayerNotifications, forKey: Keys.prayerNotifications) }
    }
    
    // Theme (0: System, 1: Light, 2: Dark)
    @Published var appTheme: Int {
        didSet { UserDefaults.standard.set(appTheme, forKey: Keys.appTheme) }
    }
    
    init() {
        self.headerPhotoData = UserDefaults.standard.data(forKey: Keys.headerPhotoData)
        
        let storedDimming = UserDefaults.standard.double(forKey: Keys.headerDimming)
        self.headerDimming = storedDimming > 0 ? storedDimming : 0.45
        
        self.headerBlur = UserDefaults.standard.double(forKey: Keys.headerBlur)
        
        if UserDefaults.standard.object(forKey: Keys.useGPSLocation) != nil {
            self.useGPSLocation = UserDefaults.standard.bool(forKey: Keys.useGPSLocation)
        } else {
            self.useGPSLocation = true
        }
        
        self.selectedCityId = UserDefaults.standard.string(forKey: Keys.selectedCityId) ?? "jakarta"
        
        if let methodRaw = UserDefaults.standard.string(forKey: Keys.calculationMethod),
           let method = CalculationMethod(rawValue: methodRaw) {
            self.calculationMethod = method
        } else {
            self.calculationMethod = .kemenag
        }
        
        let storedIhtiyat = UserDefaults.standard.integer(forKey: Keys.ihtiyatMinutes)
        self.ihtiyatMinutes = storedIhtiyat != 0 ? storedIhtiyat : 2
        
        self.hijriOffset = UserDefaults.standard.integer(forKey: Keys.hijriOffset)
        
        let storedFontSize = UserDefaults.standard.double(forKey: Keys.arabicFontSize)
        self.arabicFontSize = storedFontSize >= 18 ? storedFontSize : 24.0
        
        if let storedNotifs = UserDefaults.standard.dictionary(forKey: Keys.prayerNotifications) as? [String: Bool] {
            self.prayerNotifications = storedNotifs
        } else {
            // Default: all prayer notifications active
            self.prayerNotifications = [
                PrayerType.subuh.rawValue: true,
                PrayerType.dzuhur.rawValue: true,
                PrayerType.ashar.rawValue: true,
                PrayerType.maghrib.rawValue: true,
                PrayerType.isya.rawValue: true
            ]
        }
        
        self.appTheme = UserDefaults.standard.integer(forKey: Keys.appTheme)
    }
    
    func isNotificationEnabled(for prayer: PrayerType) -> Bool {
        prayerNotifications[prayer.rawValue] ?? true
    }
    
    func toggleNotification(for prayer: PrayerType) {
        var copy = prayerNotifications
        copy[prayer.rawValue] = !(copy[prayer.rawValue] ?? true)
        prayerNotifications = copy
    }
    
    func resetHeaderToDefault() {
        headerPhotoData = nil
        headerDimming = 0.45
        headerBlur = 0.0
    }
}
