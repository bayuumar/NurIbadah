import Foundation

// MARK: - Bundled Data Loader (100% Offline with In-Code Fallbacks)
final class DataLoader {
    static let shared = DataLoader()
    
    private init() {}
    
    // MARK: - Load Cities
    func loadCities() -> [CityLocation] {
        if let url = Bundle.main.url(forResource: "IndonesianCities", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let cities = try? JSONDecoder().decode([CityLocation].self, from: data) {
            return cities
        }
        
        // Fallback kota utama Indonesia jika file JSON bundle tidak ditemukan
        return [
            CityLocation.defaultCity,
            CityLocation(id: "surabaya", name: "Surabaya", province: "Jawa Timur", latitude: -7.2575, longitude: 112.7521, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "bandung", name: "Bandung", province: "Jawa Barat", latitude: -6.9175, longitude: 107.6191, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "medan", name: "Medan", province: "Sumatera Utara", latitude: 3.5952, longitude: 98.6722, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "semarang", name: "Semarang", province: "Jawa Tengah", latitude: -6.9667, longitude: 110.4167, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "yogyakarta", name: "Yogyakarta", province: "DI Yogyakarta", latitude: -7.7956, longitude: 110.3695, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "makassar", name: "Makassar", province: "Sulawesi Selatan", latitude: -5.1477, longitude: 119.4327, timezoneOffsetHours: 8.0, timezoneName: "WITA"),
            CityLocation(id: "palembang", name: "Palembang", province: "Sumatera Selatan", latitude: -2.9909, longitude: 104.7565, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "denpasar", name: "Denpasar", province: "Bali", latitude: -8.6705, longitude: 115.2126, timezoneOffsetHours: 8.0, timezoneName: "WITA"),
            CityLocation(id: "banda_aceh", name: "Banda Aceh", province: "Aceh", latitude: 5.5483, longitude: 95.3238, timezoneOffsetHours: 7.0, timezoneName: "WIB"),
            CityLocation(id: "balikpapan", name: "Balikpapan", province: "Kalimantan Timur", latitude: -1.2379, longitude: 116.8529, timezoneOffsetHours: 8.0, timezoneName: "WITA"),
            CityLocation(id: "ambon", name: "Ambon", province: "Maluku", latitude: -3.6547, longitude: 128.1906, timezoneOffsetHours: 9.0, timezoneName: "WIT"),
            CityLocation(id: "jayapura", name: "Jayapura", province: "Papua", latitude: -2.5337, longitude: 140.7181, timezoneOffsetHours: 9.0, timezoneName: "WIT")
        ]
    }
    
    // MARK: - Load Dzikir Items
    func loadDzikirItems() -> [DzikirItem] {
        if let url = Bundle.main.url(forResource: "DzikirData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let items = try? JSONDecoder().decode([DzikirItem].self, from: data) {
            return items
        }
        
        // Fallback autentik jika JSON belum dimuat
        return [
            DzikirItem(
                id: "pagi_ayat_kursi",
                title: "Ayat Kursi",
                arabicText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ",
                latinText: "Allahu laa ilaaha illaa huwal hayyul qayyuum, laa ta'khudzuhuu sinatuw-wa laa nawm...",
                translation: "Allah, tidak ada tuhan selain Dia. Yang Mahahidup, Yang terus-menerus mengurus (makhluk-Nya)...",
                source: "QS. Al-Baqarah: 255",
                fadhilah: "Dilindungi dari godaan setan hingga sore hari.",
                targetCount: 1,
                currentCount: 0,
                category: .pagi
            ),
            DzikirItem(
                id: "pagi_subhanallah",
                title: "Tasbih & Tahmid",
                arabicText: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
                latinText: "Subhaanallaahi wa bihamdih.",
                translation: "Mahasuci Allah dan segala puji bagi-Nya.",
                source: "HR. Muslim no. 2691",
                fadhilah: "Diampuni dosanya walau sebanyak buih lautan.",
                targetCount: 100,
                currentCount: 0,
                category: .pagi
            ),
            DzikirItem(
                id: "sore_sayyidul_istighfar",
                title: "Sayyidul Istighfar",
                arabicText: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ",
                latinText: "Allaahumma anta rabbii laa ilaaha illaa anta, khalaqtanii wa ana 'abduka...",
                translation: "Ya Allah, Engkau adalah Rabbku, tidak ada tuhan selain Engkau...",
                source: "HR. Bukhari no. 6306",
                fadhilah: "Dijamin masuk surga jika meninggal pada malam harinya.",
                targetCount: 1,
                currentCount: 0,
                category: .sore
            ),
            DzikirItem(
                id: "harian_tasbih",
                title: "Tasbih Ba'da Sholat",
                arabicText: "سُبْحَانَ اللَّهِ",
                latinText: "Subhaanallaah.",
                translation: "Mahasuci Allah.",
                source: "HR. Muslim no. 597",
                fadhilah: "Pahala dzikir setelah sholat fardhu.",
                targetCount: 33,
                currentCount: 0,
                category: .harian
            ),
            DzikirItem(
                id: "harian_tahmid",
                title: "Tahmid Ba'da Sholat",
                arabicText: "الْحَمْدُ لِلَّهِ",
                latinText: "Alhamdulillaah.",
                translation: "Segala puji bagi Allah.",
                source: "HR. Muslim no. 597",
                fadhilah: "Memenuhi timbangan kebaikan.",
                targetCount: 33,
                currentCount: 0,
                category: .harian
            ),
            DzikirItem(
                id: "harian_takbir",
                title: "Takbir Ba'da Sholat",
                arabicText: "اللَّهُ أَكْبَرُ",
                latinText: "Allaahu Akbar.",
                translation: "Allah Mahabesar.",
                source: "HR. Muslim no. 597",
                fadhilah: "Mengagungkan nama Allah.",
                targetCount: 33,
                currentCount: 0,
                category: .harian
            )
        ]
    }
}
