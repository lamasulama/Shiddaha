//
//  StoreCategory.swift
//  Shiddaha
//
//  Created by lama bin slmah on 11/02/2026.
//


//
//  StoreCategory.swift
//  Shiddaha
//
//  Created by AlAnoud Alsaaid on 23/08/1447 AH.
//

import Foundation

// MARK: - STORE CATEGORY
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

// MARK: - STORE ITEM
struct StoreItem: Identifiable {
    let id = UUID()
    let imageName: String
    let price: Int
    let category: StoreCategory
}