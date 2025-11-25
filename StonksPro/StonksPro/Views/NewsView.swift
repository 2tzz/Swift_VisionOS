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
                } else if isLoading {
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
                                                .foregroundStyle(.blue)
                                                
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
                                                                .background(Color.green.opacity(0.15))
                                                                .foregroundStyle(.green)
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
                    Picker("Topic", selection: $selectedTopic) {
                        Text("All").tag("")
                        Text("Technology").tag("technology")
                        Text("Finance").tag("finance")
                        Text("Earnings").tag("earnings")
                        Text("IPO").tag("ipo")
                        Text("Blockchain").tag("blockchain")
                    }
                    .pickerStyle(.menu)

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
