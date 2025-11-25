//
//  FavoritesManager.swift
//  StonksPro
//
//  Created on 11/25/25.
//

import SwiftUI
import Observation

@Observable class FavoritesManager {
    static let shared = FavoritesManager()
    
    var favoriteCryptoIds: Set<String> = []
    
    private let favoritesKey = "favoriteCryptoIds"
    
    init() {
        loadFavorites()
    }
    
    func isFavorite(_ cryptoId: String) -> Bool {
        return favoriteCryptoIds.contains(cryptoId)
    }
    
    func toggleFavorite(_ cryptoId: String) {
        if favoriteCryptoIds.contains(cryptoId) {
            favoriteCryptoIds.remove(cryptoId)
        } else {
            favoriteCryptoIds.insert(cryptoId)
        }
        saveFavorites()
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteCryptoIds), forKey: favoritesKey)
    }
    
    private func loadFavorites() {
        if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favoriteCryptoIds = Set(saved)
        }
    }
}
