import Foundation
import SwiftData
import SwiftUI

// MARK: - Muhasabah Category / Mood Enum
enum MuhasabahCategory: String, CaseIterable, Identifiable, Codable {
    case all = "Semua"
    case syukur = "Syukur"
    case muhasabah = "Muhasabah"
    case doa = "Doa"
    case harapan = "Harapan"
    case evaluasi = "Evaluasi Diri"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .syukur: return "heart.fill"
        case .muhasabah: return "sparkles"
        case .doa: return "hands.and.sparkles.fill"
        case .harapan: return "sunrise.fill"
        case .evaluasi: return "checklist"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color.gray
        case .syukur: return Color.pink
        case .muhasabah: return Color.teal
        case .doa: return Color.purple
        case .harapan: return Color.orange
        case .evaluasi: return Color.blue
        }
    }
}

// MARK: - SwiftData Model for Muhasabah Journal
@Model
final class MuhasabahNote {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var categoryMood: String = MuhasabahCategory.muhasabah.rawValue
    
    // Custom photo attachment stored as local compressed binary data
    @Attribute(.externalStorage)
    var photoData: Data? = nil
    
    var isFavorite: Bool = false
    
    init(
        title: String,
        content: String,
        categoryMood: MuhasabahCategory = .muhasabah,
        photoData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.categoryMood = categoryMood.rawValue
        self.photoData = photoData
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.isFavorite = false
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: createdAt)
    }
    
    var category: MuhasabahCategory {
        MuhasabahCategory(rawValue: categoryMood) ?? .muhasabah
    }
}
