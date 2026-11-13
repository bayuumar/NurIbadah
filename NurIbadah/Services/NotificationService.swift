import Foundation
import UserNotifications

// MARK: - Local Prayer Notification Service (100% Offline)
final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    /// Meminta izin notifikasi lokal kepada pengguna
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    /// Memeriksa status izin notifikasi
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    /// Menjadwalkan pengingat sholat berdasarkan jadwal hari ini
    func schedulePrayerNotifications(
        schedule: PrayerSchedule,
        cityName: String,
        enabledPrayers: [PrayerType: Bool]
    ) {
        let center = UNUserNotificationCenter.current()
        
        // Bersihkan notifikasi sholat sebelumnya
        let prayerIdentifiers = PrayerType.allCases.map { "prayer_\($0.rawValue)" }
        center.removePendingNotificationRequests(withIdentifiers: prayerIdentifiers)
        
        let now = Date()
        let calendar = Calendar.current
        
        for prayer in PrayerType.allCases {
            // Abaikan waktu Terbit (bukan sholat fardhu) atau jika dinonaktifkan oleh pengguna
            guard prayer.isFardhu, (enabledPrayers[prayer] ?? true) else { continue }
            guard let prayerDate = schedule.time(for: prayer) else { continue }
            
            // Jadwalkan hanya jika waktu sholat belum lewat untuk hari ini
            var targetDate = prayerDate
            if targetDate <= now {
                // Jika sudah lewat hari ini, jadwalkan untuk besok di jam yang sama
                if let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: prayerDate) {
                    targetDate = tomorrowDate
                } else {
                    continue
                }
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Waktu \(prayer.displayName) Telah Tiba"
            content.body = "Telah masuk waktu sholat \(prayer.displayName) untuk wilayah \(cityName) dan sekitarnya. Mari tunaikan ibadah tepat waktu."
            content.sound = .default
            content.categoryIdentifier = "PRAYER_REMINDER"
            
            let triggerComponents = calendar.dateComponents([.hour, .minute, .second], from: targetDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "prayer_\(prayer.rawValue)",
                content: content,
                trigger: trigger
            )
            
            center.add(request) { error in
                if let error = error {
                    print("Error scheduling notification for \(prayer.displayName): \(error.localizedDescription)")
                }
            }
        }
    }
}
