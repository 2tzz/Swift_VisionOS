//
//  AssetClassModel.swift
//  StonksPro
//
//  Created by Peter Graham on 6/25/23.
//
import SwiftUI

// https://medium.com/@alessandromanilii/swiftui-navigationsplitview-b5ba2df07bb4
struct AssetClassStruct: Identifiable, Hashable {
    let title: String
    let id = UUID()
}

var stocksAssetClass = AssetClassStruct(title: "Stocks")
var cryptoAssetClass = AssetClassStruct(title: "Crypto")
var favoritesAssetClass = AssetClassStruct(title: "Favorites")
var optionsAssetClass = AssetClassStruct(title: "Overview")

extension AssetClassStruct {

    static var listAll: [AssetClassStruct] {
        [
         cryptoAssetClass,
         stocksAssetClass,
         favoritesAssetClass,
         optionsAssetClass
        ]
    }

    static var stocks: AssetClassStruct {
        return stocksAssetClass
    }

    static var crypto: AssetClassStruct {
        return cryptoAssetClass
    }

    static var options: AssetClassStruct {
        return optionsAssetClass
    }

    static var favorites: AssetClassStruct {
        return favoritesAssetClass
    }

    // TODO: better way?
    var isStocks: Bool {
        return self.id == stocksAssetClass.id
    }

    var isCrypto: Bool {
        return self.id == cryptoAssetClass.id
    }

    var isOptions: Bool {
        return self.id == optionsAssetClass.id
    }

    var isFavorites: Bool {
        return self.id == favoritesAssetClass.id
    }
}
