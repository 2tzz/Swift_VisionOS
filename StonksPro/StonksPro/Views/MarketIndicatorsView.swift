//
//  MarketIndicatorsView.swift
//  StonksPro
//
//  Created on 11/25/25.
//

import SwiftUI

struct MarketIndicatorsView: View {
    @State private var isLoading: Bool = true
    @State private var topGainers: [AlphaVantageTopAsset] = []
    @State private var topLosers: [AlphaVantageTopAsset] = []
    @State private var mostActive: [AlphaVantageTopAsset] = []
    @State private var errorMessage: String?
    @State private var lastUpdated: String = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unable to load data")
                            .font(.title2).bold()
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else if isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Last Updated
                            if !lastUpdated.isEmpty {
                                Text("Last updated: \(lastUpdated)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.horizontal)
                            }
                            
                            // Top Gainers
                            MarketSection(
                                title: "Top Gainers",
                                icon: "arrow.up.circle.fill",
                                iconColor: .green,
                                assets: topGainers
                            )
                            
                            // Top Losers
                            MarketSection(
                                title: "Top Losers",
                                icon: "arrow.down.circle.fill",
                                iconColor: .red,
                                assets: topLosers
                            )
                            
                            // Most Active
                            MarketSection(
                                title: "Most Active",
                                icon: "chart.line.uptrend.xyaxis",
                                iconColor: .blue,
                                assets: mostActive
                            )
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Market Overview")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task {
                            await loadData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await AlphaVantageApiClient.fetchTopMovers(
                apiKey: "2GIZQI8TNR9F628T",
                useMockData: false
            )
            
            topGainers = Array(response.top_gainers.prefix(10))
            topLosers = Array(response.top_losers.prefix(10))
            mostActive = Array(response.most_actively_traded.prefix(10))
            lastUpdated = response.last_updated
            
            print("Successfully loaded market data")
        } catch {
            print("Error loading market data: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct MarketSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let assets: [AlphaVantageTopAsset]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(Array(assets.enumerated()), id: \.element.ticker) { index, asset in
                    MarketAssetRow(asset: asset, rank: index + 1)
                }
            }
        }
    }
}

struct MarketAssetRow: View {
    let asset: AlphaVantageTopAsset
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // Ticker
            Text(asset.ticker)
                .font(.headline)
                .fontWeight(.semibold)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatDollar(value: Float(asset.price) ?? 0))
                    .font(.body)
                    .fontWeight(.medium)
                
                // Change Amount
                Text(asset.change_amount)
                    .font(.caption2)
                    .foregroundStyle(changeColor(asset.change_amount))
            }
            
            // Change Percentage
            HStack(spacing: 4) {
                Image(systemName: changeIcon(asset.change_amount))
                    .font(.caption)
                Text(asset.change_percentage)
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(changeColor(asset.change_amount))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(changeColor(asset.change_amount).opacity(0.15))
            .cornerRadius(8)
            
            // Volume
            VStack(alignment: .trailing, spacing: 2) {
                Text("Volume")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(formatVolume(asset.volume))
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 80)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func changeColor(_ change: String) -> Color {
        if change.hasPrefix("-") {
            return .red
        } else {
            return .green
        }
    }
    
    private func changeIcon(_ change: String) -> String {
        if change.hasPrefix("-") {
            return "arrow.down.right"
        } else {
            return "arrow.up.right"
        }
    }
    
    private func formatVolume(_ volume: String) -> String {
        guard let volumeInt = Int(volume) else { return volume }
        
        if volumeInt >= 1_000_000_000 {
            return String(format: "%.2fB", Double(volumeInt) / 1_000_000_000)
        } else if volumeInt >= 1_000_000 {
            return String(format: "%.2fM", Double(volumeInt) / 1_000_000)
        } else if volumeInt >= 1_000 {
            return String(format: "%.2fK", Double(volumeInt) / 1_000)
        } else {
            return volume
        }
    }
}

#Preview {
    MarketIndicatorsView()
}
