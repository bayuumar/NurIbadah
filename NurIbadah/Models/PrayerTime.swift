import Foundation
import SwiftUI

// MARK: - Prayer Type Enum
enum PrayerType: String, CaseIterable, Identifiable, Codable {
    case subuh = "Subuh"
    case terbit = "Terbit"
    case dzuhur = "Dzuhur"
    case ashar = "Ashar"
    case maghrib = "Maghrib"
    case isya = "Isya"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var arabicName: String {
        switch self {
        case .subuh: return "الفجر"
        case .terbit: return "الشروق"
        case .dzuhur: return "الظهر"
        case .ashar: return "العصر"
        case .maghrib: return "المغرب"
        case .isya: return "العشاء"
        }
    }
    
    var iconName: String {
        switch self {
        case .subuh: return "moon.stars.fill"
        case .terbit: return "sunrise.fill"
        case .dzuhur: return "sun.max.fill"
        case .ashar: return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isya: return "moon.fill"
        }
    }
    
    var isFardhu: Bool {
        self != .terbit
    }
    
    var color: Color {
        switch self {
        case .subuh: return Color.indigo
        case .terbit: return Color.orange
        case .dzuhur: return Color.yellow
        case .ashar: return Color.orange
        case .maghrib: return Color.red
        case .isya: return Color.purple
        }
    }
}

// MARK: - Prayer Calculation Method
enum CalculationMethod: String, CaseIterable, Identifiable, Codable {
    case kemenag = "Kemenag RI (Subuh 20°, Isya 18°)"
    case mwl = "Muslim World League (Subuh 18°, Isya 17°)"
    case egyptian = "Egyptian General Authority (Subuh 19.5°, Isya 17.5°)"
    case ummAlQura = "Umm al-Qura (Subuh 18.5°, Isya +90m)"
    
    var id: String { rawValue }
    
    var fajrAngle: Double {
        switch self {
        case .kemenag: return 20.0
        case .mwl: return 18.0
        case .egyptian: return 19.5
        case .ummAlQura: return 18.5
        }
    }
    
    var ishaAngle: Double {
        switch self {
        case .kemenag: return 18.0
        case .mwl: return 17.0
        case .egyptian: return 17.5
        case .ummAlQura: return 0.0 // 90 min after Maghrib
        }
    }
    
    var isIshaInterval: Bool {
        self == .ummAlQura
    }
    
    var ishaIntervalMinutes: Int {
        90
    }
}

// MARK: - Daily Prayer Schedule Model
struct PrayerSchedule: Identifiable, Equatable {
    var id: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    let date: Date
    let times: [PrayerType: Date]
    
    func time(for type: PrayerType) -> Date? {
        times[type]
    }
    
    func formattedTime(for type: PrayerType) -> String {
        guard let time = times[type] else { return "--:--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    /// Menentukan waktu sholat yang sedang aktif atau berikutnya
    func currentAndNextPrayer(at currentDate: Date = Date()) -> (current: PrayerType?, next: PrayerType, nextTime: Date, remainingSeconds: TimeInterval) {
        let sortedTypes: [PrayerType] = [.subuh, .terbit, .dzuhur, .ashar, .maghrib, .isya]
        
        var current: PrayerType? = nil
        var next: PrayerType = .subuh
        var nextTime: Date = date
        
        for (index, type) in sortedTypes.enumerated() {
            guard let prayerDate = times[type] else { continue }
            if currentDate >= prayerDate {
                current = type
            } else {
                next = type
                nextTime = prayerDate
                let remaining = nextTime.timeIntervalSince(currentDate)
                return (current, next, nextTime, max(0, remaining))
            }
        }
        
        // Jika sudah melewati Isya, waktu berikutnya adalah Subuh besok
        let calendar = Calendar.current
        if let subuhToday = times[.subuh],
           let subuhTomorrow = calendar.date(byAdding: .day, value: 1, to: subuhToday) {
            next = .subuh
            nextTime = subuhTomorrow
        }
        
        let remaining = nextTime.timeIntervalSince(currentDate)
        return (current, next, nextTime, max(0, remaining))
    }
}
