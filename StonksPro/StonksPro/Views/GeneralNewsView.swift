//
//  GeneralNewsView.swift
//  StonksPro
//
//  Created on 11/25/25.
//

import SwiftUI

struct GeneralNewsView: View {
    @State private var isLoading: Bool = false
    @State private var articles: [StockNewsArticle] = []
    @State private var errorMessage: String?
    @State private var selectedCategory: NewsCategory = .general
    @State private var currentPage: Int = 1
    
    enum NewsCategory: String, CaseIterable, Identifiable {
        case general = "general"
        case allTickers = "alltickers"
        case forex = "forex"
        case crypto = "crypto"
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .general: return "General"
            case .allTickers: return "All Tickers"
            case .forex: return "Forex"
            case .crypto: return "Crypto"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let errorMessage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unable to load news")
                            .font(.title2).bold()
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                } else if isLoading && articles.isEmpty {
                    ProgressView()
                } else if articles.isEmpty {
                    Text("No news available.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(articles) { article in
                                Button {
                                    if let url = URL(string: article.news_url) {
                                        #if os(visionOS)
                                        Task {
                                            await UIApplication.shared.open(url)
                                        }
                                        #endif
                                    }
                                } label: {
                                    VStack(alignment: .leading, spacing: 0) {
                                        // Image
                                        if let urlString = article.image_url,
                                           !urlString.isEmpty,
                                           let url = URL(string: urlString) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.2))
                                                        .overlay {
                                                            ProgressView()
                                                        }
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                case .failure:
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.1))
                                                        .overlay {
                                                            Image(systemName: "photo")
                                                                .font(.largeTitle)
                                                                .foregroundStyle(.secondary)
                                                        }
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 200)
                                            .clipped()
                                        }
                                        
                                        // Content
                                        VStack(alignment: .leading, spacing: 12) {
                                            // Title
                                            Text(article.title)
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)
                                                .lineLimit(3)
                                                .multilineTextAlignment(.leading)
                                            
                                            // Summary
                                            Text(article.text)
                                                .font(.body)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(4)
                                                .multilineTextAlignment(.leading)
                                            
                                            // Metadata
                                            HStack(spacing: 12) {
                                                // Source
                                                HStack(spacing: 4) {
                                                    Image(systemName: "newspaper")
                                                        .font(.caption2)
                                                    Text(article.source_name)
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                }
                                                .foregroundStyle(.primary)
                                                
                                                Spacer()
                                                
                                                // Sentiment
                                                if let sentiment = article.sentiment {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: sentimentIcon(sentiment))
                                                            .font(.caption2)
                                                        Text(sentiment)
                                                            .font(.caption)
                                                    }
                                                    .foregroundStyle(sentimentColor(sentiment))
                                                }
                                                
                                                // Date
                                                HStack(spacing: 4) {
                                                    Image(systemName: "clock")
                                                        .font(.caption2)
                                                    Text(formatDate(article.date))
                                                        .font(.caption)
                                                }
                                                .foregroundStyle(.secondary)
                                            }
                                            
                                            // Type badge
                                            if let type = article.type {
                                                Text(type)
                                                    .font(.caption2)
                                                    .fontWeight(.medium)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.white.opacity(0.15))
                                                    .foregroundStyle(.primary)
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(16)
                                    }
                                    .background(.ultraThickMaterial)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Load More Button
                            if !isLoading {
                                Button {
                                    currentPage += 1
                                    Task {
                                        await loadNews(append: true)
                                    }
                                } label: {
                                    HStack {
                                        Text("Load More")
                                            .font(.callout)
                                            .fontWeight(.medium)
                                        Image(systemName: "arrow.down.circle")
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            } else {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("General Trending News")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(NewsCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Button {
                        Task {
                            currentPage = 1
                            await loadNews(reset: true)
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .padding()
            .task {
                await loadNews()
            }
            .task(id: selectedCategory) {
                currentPage = 1
                await loadNews(reset: true)
            }
        }
    }
    
    private func loadNews(reset: Bool = false, append: Bool = false) async {
        if reset {
            currentPage = 1
            articles = []
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await StockNewsApiClient.fetchNews(
                token: "yfqiw4pyonymlim2epd1sgf2hmehkuproiu17uh5",
                section: StockNewsSection(rawValue: selectedCategory.rawValue) ?? .general,
                type: .all,
                items: 3,
                page: currentPage
            )
            
            if append {
                articles.append(contentsOf: result)
            } else {
                articles = result
            }
            print("Successfully loaded \(result.count) articles")
        } catch {
            print("Error loading news: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "MMM d, h:mm a"
            return displayFormatter.string(from: date)
        }
        return dateString
    }
    
    private func sentimentIcon(_ sentiment: String) -> String {
        switch sentiment.lowercased() {
        case "positive": return "arrow.up.circle.fill"
        case "negative": return "arrow.down.circle.fill"
        default: return "minus.circle.fill"
        }
    }
    
    private func sentimentColor(_ sentiment: String) -> Color {
        switch sentiment.lowercased() {
        case "positive": return .green
        case "negative": return .red
        default: return .orange
        }
    }
}

#Preview {
    GeneralNewsView()
}
