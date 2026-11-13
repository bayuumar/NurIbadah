import Foundation
import SwiftUI

// MARK: - Dzikir Category
enum DzikirCategory: String, CaseIterable, Identifiable, Codable {
    case pagi = "pagi"
    case sore = "sore"
    case harian = "harian"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .pagi: return "Dzikir Pagi"
        case .sore: return "Dzikir Sore"
        case .harian: return "Dzikir Harian"
        }
    }
    
    var subtitle: String {
        switch self {
        case .pagi: return "Waktu Subuh hingga terbit matahari atau menjelang siang"
        case .sore: return "Waktu Ashar hingga terbenam matahari atau menjelang Isya"
        case .harian: return "Dzikir ba'da sholat fardhu & doa harian mustajab"
        }
    }
    
    var iconName: String {
        switch self {
        case .pagi: return "sun.and.horizon.fill"
        case .sore: return "sunset.fill"
        case .harian: return "hands.sparkles.fill"
        }
    }
}

// MARK: - Dzikir Item Model
struct DzikirItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let arabicText: String
    let latinText: String
    let translation: String
    let source: String
    let fadhilah: String?
    let targetCount: Int
    var currentCount: Int
    let category: DzikirCategory
    
    var isCompleted: Bool {
        currentCount >= targetCount
    }
    
    var progressFraction: Double {
        guard targetCount > 0 else { return 0 }
        return min(1.0, Double(currentCount) / Double(targetCount))
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, arabicText, latinText, translation, source, fadhilah, targetCount, currentCount, category
    }
    
    init(
        id: String,
        title: String,
        arabicText: String,
        latinText: String,
        translation: String,
        source: String,
        fadhilah: String? = nil,
        targetCount: Int,
        currentCount: Int = 0,
        category: DzikirCategory
    ) {
        self.id = id
        self.title = title
        self.arabicText = arabicText
        self.latinText = latinText
        self.translation = translation
        self.source = source
        self.fadhilah = fadhilah
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.category = category
    }
}
