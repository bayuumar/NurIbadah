import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - Dzikir View Model
@MainActor
final class DzikirViewModel: ObservableObject {
    @Published var allItems: [DzikirItem] = []
    @Published var selectedCategory: DzikirCategory = .pagi
    @Published var focusedItem: DzikirItem? = nil
    @Published var arabicFontSize: Double = 26.0
    
    private let dataLoader = DataLoader.shared
    private let settings = AppSettings.shared
    private let lightImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyNotification = UINotificationFeedbackGenerator()
    
    init() {
        self.arabicFontSize = settings.arabicFontSize
        loadData()
        lightImpact.prepare()
        heavyNotification.prepare()
    }
    
    func loadData() {
        self.allItems = dataLoader.loadDzikirItems()
    }
    
    var currentCategoryItems: [DzikirItem] {
        allItems.filter { $0.category == selectedCategory }
    }
    
    var completedCountInCategory: Int {
        currentCategoryItems.filter { $0.isCompleted }.count
    }
    
    var totalCountInCategory: Int {
        currentCategoryItems.count
    }
    
    var categoryProgressFraction: Double {
        guard totalCountInCategory > 0 else { return 0 }
        return Double(completedCountInCategory) / Double(totalCountInCategory)
    }
    
    // MARK: - Interactive Tasbih Logic
    func incrementCount(for item: DzikirItem) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        
        if allItems[index].currentCount < allItems[index].targetCount {
            allItems[index].currentCount += 1
            
            // Getaran haptic interaktif
            if allItems[index].currentCount >= allItems[index].targetCount {
                // Target tercapai! Berikan haptic sukses
                heavyNotification.notificationOccurred(.success)
            } else {
                lightImpact.impactOccurred()
            }
        }
        
        // Update focusedItem jika sedang di modal fokus
        if focusedItem?.id == item.id {
            focusedItem = allItems[index]
        }
    }
    
    func resetCount(for item: DzikirItem) {
        guard let index = allItems.firstIndex(where: { $0.id == item.id }) else { return }
        allItems[index].currentCount = 0
        lightImpact.impactOccurred()
        
        if focusedItem?.id == item.id {
            focusedItem = allItems[index]
        }
    }
    
    func resetAllInCategory() {
        for index in allItems.indices {
            if allItems[index].category == selectedCategory {
                allItems[index].currentCount = 0
            }
        }
        lightImpact.impactOccurred()
    }
    
    func setArabicFontSize(_ size: Double) {
        let clamped = min(38.0, max(18.0, size))
        self.arabicFontSize = clamped
        settings.arabicFontSize = clamped
    }
}
