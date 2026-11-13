import Foundation

// MARK: - Hijri Date Conversion Service (100% Offline)
final class HijriDateService {
    static let shared = HijriDateService()
    
    private let islamicCalendar: Calendar
    private let hijriMonthNames = [
        1: "Muharram",
        2: "Safar",
        3: "Rabi'ul Awwal",
        4: "Rabi'ul Akhir",
        5: "Jumadil Awwal",
        6: "Jumadil Akhir",
        7: "Rajab",
        8: "Sya'ban",
        9: "Ramadhan",
        10: "Syawwal",
        11: "Dzulqa'dah",
        12: "Dzulhijjah"
    ]
    
    private init() {
        var cal = Calendar(identifier: .islamicUmmAlQura)
        cal.locale = Locale(identifier: "id_ID")
        self.islamicCalendar = cal
    }
    
    /// Mengonversi tanggal Masehi ke string tanggal Hijriah dengan penyesuaian hari offset
    func formatHijriDate(from date: Date = Date(), dayOffset: Int = 0) -> String {
        let adjustedDate = islamicCalendar.date(byAdding: .day, value: dayOffset, to: date) ?? date
        
        let day = islamicCalendar.component(.day, from: adjustedDate)
        let month = islamicCalendar.component(.month, from: adjustedDate)
        let year = islamicCalendar.component(.year, from: adjustedDate)
        
        let monthName = hijriMonthNames[month] ?? "Bulan \(month)"
        return "\(day) \(monthName) \(year) H"
    }
    
    /// Mengonversi tanggal Masehi ke format lengkap Bahasa Indonesia
    func formatGregorianDate(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
}
