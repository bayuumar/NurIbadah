import SwiftUI
import SwiftData
import UserNotifications

@main
struct NurIbadahApp: App {
    // ModelContainer untuk SwiftData (100% Offline Storage)
    let container: ModelContainer
    
    init() {
        do {
            let schema = Schema([MuhasabahNote.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [config])
            
            // Masukkan contoh catatan awal jika masih kosong
            preloadSampleNoteIfNeeded(context: container.mainContext)
        } catch {
            fatalError("Gagal menginisialisasi SwiftData ModelContainer: \(error.localizedDescription)")
        }
        
        // Setup delegate notifikasi lokal
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
        }
    }
    
    /// Preload data catatan awal yang ramah dan inspiratif
    @MainActor
    private func preloadSampleNoteIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<MuhasabahNote>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            let welcomeNote = MuhasabahNote(
                title: "Selamat Datang di NurIbadah",
                content: "Alhamdulillah, hari ini mulai menggunakan aplikasi NurIbadah. Semoga aplikasi ini dapat membantu menjaga sholat tepat waktu, istiqomah dalam dzikir pagi dan petang, serta menjadi tempat mencatat refleksi hati harian.",
                categoryMood: .syukur,
                createdAt: Date()
            )
            context.insert(welcomeNote)
            try? context.save()
        }
    }
}

// MARK: - Local Notification Delegate
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Tampilkan banner dan suara meskipun aplikasi sedang aktif di foreground
        completionHandler([.banner, .sound, .badge])
    }
}
