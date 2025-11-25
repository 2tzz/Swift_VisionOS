//
//  StonksListView.swift
//  StonksPro
//
//  Created by Peter Graham on 6/25/23.
//

import SwiftUI

struct StonksListViewItemDollarChange: View {
    @State var header: String
    @State var value: Float?

    var body: some View {
        VStack {
            Text(header).font(.callout).bold()
            Text(formatDollar(value: value ?? 0)).foregroundColor(textColorForDollar(value: value ?? 0))
        }.padding(.trailing)
    }
}

struct StonksListViewItemPercentageChange: View {
    @State var header: String
    @State var percent: Float?

    var body: some View {
        VStack {
            Text(header).font(.callout).bold()
            Text(formatPercent(percent: percent ?? 0)).foregroundColor(textColorForPercent(percent: percent ?? 0))
        }.padding(.trailing)
    }
}

struct StonksListView: View {
    var userSettings: UserSettingsModel
    var assetClass: AssetClassStruct

    @State var isLoading: Bool = true
    @State var cryptoAssets: [CoinGeckoAssetResponse] = []
    @State var stocks: [AlphaVantageTopAsset] = []
    @State private var favoritesManager = FavoritesManager.shared

    func fetchCryptoAssets() async {
        isLoading = true
        do {
            cryptoAssets = try await CoinGeckoApiClient.fetchTopCoins()
            print("Successfully fetched crypto", Date())
            isLoading = false
        } catch {
            print("Unable to fetch crypto", error)
        }
    }

    func fetchStocks() async {
        isLoading = true
        do {
            let response = try await AlphaVantageApiClient.fetchTopMovers(apiKey: userSettings.alphaVantageApiKey, useMockData: userSettings.useMockStockData)
            print("Successfully fetched stocks", Date())
            stocks = response.most_actively_traded
            isLoading = false
        } catch {
            print("Unable to fetch stocks", error)
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if assetClass.isStocks {
                    List(stocks, id: \.ticker) { item in
                        NavigationLink(value: item.ticker) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(item.ticker).font(.title)
                                    }
                                    Text(formatDollar(value: Float(item.price) ?? 0)).font(.title3).padding(.top, 1)
                                }.padding(0)
                                Spacer()
                                StonksListViewItemDollarChange(header: "Change $", value: Float(item.change_amount))
                                StonksListViewItemPercentageChange(header: "Change %", percent: Float(item.change_percentage.replacingOccurrences(of: "%", with: "")))
                            }
                        }.navigationDestination(for: String.self) { stockTicker in
                            if let stock = stocks.first(where: {$0.ticker == stockTicker}) {
                                StockDetailsView(userSettings: userSettings, stock: stock)
                            }
                        }
                    }
                } else if assetClass.isCrypto {
                    ScrollView {
                        let columns = [
                            GridItem(.adaptive(minimum: 220), spacing: 16)
                        ]

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(cryptoAssets, id: \.id) { item in
                                ZStack(alignment: .topTrailing) {
                                    NavigationLink(value: item.id) {
                                        VStack(spacing: 12) {
                                            VStack(spacing: 8) {
                                                AsyncImage(url: URL(string: item.image)) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 48, height: 48)

                                                Text(item.name)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                            }

                                            Text(formatDollar(value: item.current_price))
                                                .font(.title3)

                                            HStack(spacing: 8) {
                                                StonksListViewItemPercentageChange(header: "1h", percent: item.price_change_percentage_1h_in_currency)
                                                StonksListViewItemPercentageChange(header: "24h", percent: item.price_change_percentage_24h_in_currency)
                                                StonksListViewItemPercentageChange(header: "7d", percent: item.price_change_percentage_7d_in_currency)
                                            }
                                            .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 220)
                                        .padding(16)
                                        .background(.ultraThickMaterial)
                                        .cornerRadius(16)
                                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // 3-dot menu
                                    Menu {
                                        Button {
                                            favoritesManager.toggleFavorite(item.id)
                                        } label: {
                                            Label(
                                                favoritesManager.isFavorite(item.id) ? "Remove from Favorites" : "Add to Favorites",
                                                systemImage: favoritesManager.isFavorite(item.id) ? "star.fill" : "star"
                                            )
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.primary)
                                            .padding(12)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .navigationDestination(for: String.self) { cryptoId in
                        if let cryptoAsset = cryptoAssets.first(where: {$0.id == cryptoId}) {
                            CryptoDetailsView(cryptoAsset: cryptoAsset)
                        }
                    }
                } else if assetClass.isFavorites {
                    ScrollView {
                        let columns = [
                            GridItem(.adaptive(minimum: 220), spacing: 16)
                        ]
                        
                        let favoriteCryptos = cryptoAssets.filter { favoritesManager.isFavorite($0.id) }

                        if favoriteCryptos.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "star.slash")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                Text("No favorite cryptocurrencies yet")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                                Text("Add cryptocurrencies to favorites from the Crypto tab")
                                    .font(.callout)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(favoriteCryptos, id: \.id) { item in
                                    ZStack(alignment: .topTrailing) {
                                        NavigationLink(value: item.id) {
                                            VStack(spacing: 12) {
                                                VStack(spacing: 8) {
                                                    AsyncImage(url: URL(string: item.image)) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .frame(width: 48, height: 48)

                                                    Text(item.name)
                                                        .font(.headline)
                                                        .multilineTextAlignment(.center)
                                                        .lineLimit(2)
                                                }

                                                Text(formatDollar(value: item.current_price))
                                                    .font(.title3)

                                                HStack(spacing: 8) {
                                                    StonksListViewItemPercentageChange(header: "1h", percent: item.price_change_percentage_1h_in_currency)
                                                    StonksListViewItemPercentageChange(header: "24h", percent: item.price_change_percentage_24h_in_currency)
                                                    StonksListViewItemPercentageChange(header: "7d", percent: item.price_change_percentage_7d_in_currency)
                                                }
                                                .font(.caption)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 220)
                                            .padding(16)
                                            .background(.ultraThickMaterial)
                                            .cornerRadius(16)
                                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        // 3-dot menu
                                        Menu {
                                            Button {
                                                favoritesManager.toggleFavorite(item.id)
                                            } label: {
                                                Label("Remove from Favorites", systemImage: "star.fill")
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.primary)
                                                .padding(12)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .navigationDestination(for: String.self) { cryptoId in
                        if let cryptoAsset = cryptoAssets.first(where: {$0.id == cryptoId}) {
                            CryptoDetailsView(cryptoAsset: cryptoAsset)
                        }
                    }

                } else if assetClass.isOptions {
                    MarketIndicatorsView()
                } else {
                    Text("Not yet implemented!")
                }
            }
            .navigationTitle(assetClass.title)
            .padding()
            .task(id: assetClass.id) {
                if assetClass.isCrypto || assetClass.isFavorites {
                    await fetchCryptoAssets()
                } else if assetClass.isStocks {
                    await fetchStocks()
                }
            }
        }
    }
}

#Preview {
    VStack {
        let previewUserSettings: UserSettingsModel = UserSettingsModel()
        let previewAssetClass: AssetClassStruct = AssetClassStruct.stocks
        StonksListView(userSettings: previewUserSettings, assetClass: previewAssetClass)
    }
}
