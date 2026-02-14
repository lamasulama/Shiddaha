// StoreCategory.swift

import Foundation

enum StoreCategory: String, Identifiable, CaseIterable {
    case tents
    case characters

    var id: String { rawValue }

    var iconAssetName: String {
        switch self {
        case .tents: return "button_tent"
        case .characters: return "ch_button"
        }
    }
}

struct StoreItem: Identifiable {
    let id = UUID()
    let imageName: String
    let price: Int
    let category: StoreCategory
}
