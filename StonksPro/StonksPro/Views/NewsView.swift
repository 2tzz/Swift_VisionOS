//
//  NewsView.swift
//  StonksPro
//
//  Created by Cascade on 11/25/25.
//

import SwiftUI

struct NewsView: View {
    var userSettings: UserSettingsModel
    
    @State private var isLoading: Bool = false
    @State private var articles: [AlphaVantageNewsArticle] = []
    @State private var errorMessage: String?
    @State private var selectedTopic: String = ""
    @State private var searchText: String = ""
    @State private var selectedSource: String = "All Sources"
    @State private var sortBy: SortOption = .date
    
    enum SortOption: String, CaseIterable {
        case date = "Latest First"
        case relevance = "Most Relevant"
    }
    
    var filteredArticles: [AlphaVantageNewsArticle] {
        var results = articles
        
        // Filter by search text
        if !searchText.isEmpty {
            results = results.filter { article in
                article.title.localizedCaseInsensitiveContains(searchText) ||
                article.summary.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by source
        if selectedSource != "All Sources" {
            results = results.filter { $0.source == selectedSource }
        }
        
        // Sort
        switch sortBy {
        case .date:
            results.sort { $0.time_published > $1.time_published }
        case .relevance:
            // Keep original order (API returns by relevance)
            break
        }
        
        return results
    }
    
    var availableSources: [String] {
        var sources = Set(articles.map { $0.source })
        return ["All Sources"] + sources.sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .font(.body)
                        
                        TextField("Search articles...", text: $searchText)
                            .textFieldStyle(.plain)
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThickMaterial)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                
                // Advanced Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Topic Filter
                        Menu {
                            Button {
                                selectedTopic = ""
                            } label: {
                                HStack {
                                    Text("All Topics")
                                    if selectedTopic.isEmpty {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Divider()
                            
                            ForEach(["technology", "finance", "earnings", "ipo", "blockchain", "mergers_and_acquisitions", "energy_transportation"], id: \.self) { topic in
                                Button {
                                    selectedTopic = topic
                                } label: {
                                    HStack {
                                        Text(topic.replacingOccurrences(of: "_", with: " ").capitalized)
                                        if selectedTopic == topic {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "tag.fill")
                                    .font(.caption)
                                Text(selectedTopic.isEmpty ? "All Topics" : selectedTopic.replacingOccurrences(of: "_", with: " ").capitalized)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedTopic.isEmpty ? Color.gray.opacity(0.15) : Color.white.opacity(0.2))
                            .foregroundStyle(.primary)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        
                        // Source Filter
                        Menu {
                            ForEach(availableSources, id: \.self) { source in
                                Button {
                                    selectedSource = source
                                } label: {
                                    HStack {
                                        Text(source)
                                        if selectedSource == source {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "newspaper.fill")
                                    .font(.caption)
                                Text(selectedSource)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedSource == "All Sources" ? Color.gray.opacity(0.15) : Color.white.opacity(0.2))
                            .foregroundStyle(.primary)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        
                        // Sort Filter
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    sortBy = option
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortBy == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.caption)
                                Text(sortBy.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .foregroundStyle(.primary)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        
                        // Clear Filters Button
                        if selectedSource != "All Sources" || !selectedTopic.isEmpty || !searchText.isEmpty {
                            Button {
                                searchText = ""
                                selectedTopic = ""
                                selectedSource = "All Sources"
                                sortBy = .date
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                    Text("Clear")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.2))
                                .foregroundStyle(.primary)
                                .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(.regularMaterial)
                
                Divider()
                
                // Results Count
                if !isLoading && !articles.isEmpty {
                    HStack {
                        Text("\(filteredArticles.count) article\(filteredArticles.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(.regularMaterial)
                }
                
                // Content
                Group {
                    if let errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Unable to load news")
                                .font(.title2).bold()
                            Text(errorMessage)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                    } else if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredArticles.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: searchText.isEmpty ? "newspaper" : "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text(searchText.isEmpty ? "No news available." : "No articles match your search.")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(filteredArticles) { article in
                                    Button {
                                        if let url = URL(string: article.url) {
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
                                                Text(article.summary)
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
                                                        Text(article.source)
                                                            .font(.caption)
                                                            .fontWeight(.medium)
                                                    }
                                                    .foregroundStyle(.primary)
                                                    
                                                    Spacer()
                                                    
                                                    // Date
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "clock")
                                                            .font(.caption2)
                                                        Text(formatDate(article.time_published))
                                                            .font(.caption)
                                                    }
                                                    .foregroundStyle(.secondary)
                                                }
                                                
                                                // Topics (if available)
                                                if let topics = article.topics, !topics.isEmpty {
                                                    ScrollView(.horizontal, showsIndicators: false) {
                                                        HStack(spacing: 8) {
                                                            ForEach(topics.prefix(3), id: \.topic) { topic in
                                                                Text(topic.topic.capitalized)
                                                                    .font(.caption2)
                                                                    .fontWeight(.medium)
                                                                    .padding(.horizontal, 10)
                                                                    .padding(.vertical, 4)
                                                                    .background(Color.white.opacity(0.15))
                                                                    .foregroundStyle(.primary)
                                                                    .cornerRadius(8)
                                                            }
                                                        }
                                                    }
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
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .navigationTitle("Market News")
                .toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        Button {
                            Task {
                                await loadNews()
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
                .task(id: selectedTopic) {
                    await loadNews()
                }
            }
        }
    }

    private func loadNews() async {
            isLoading = true
            errorMessage = nil
            do {
                let result = try await AlphaVantageApiClient.fetchNews(
                    apiKey: "2GIZQI8TNR9F628T",
                    topic: selectedTopic,
                    limit: 50
                )
                articles = result
                print("Successfully loaded \(result.count) articles")
            } catch {
                print("Error loading news: \(error)")
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
        
        private func formatDate(_ dateString: String) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmm'Z'"
            
            if let date = formatter.date(from: dateString) {
                let displayFormatter = DateFormatter()
                displayFormatter.dateFormat = "MMM d, h:mm a"
                return displayFormatter.string(from: date)
            }
            return dateString
        }
    }

#Preview {
    let previewUserSettings = UserSettingsModel()
    NewsView(userSettings: previewUserSettings)
}
