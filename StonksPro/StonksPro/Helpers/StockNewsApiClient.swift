//
//  StockNewsApiClient.swift
//  StonksPro
//
//  Created by Cascade on 11/25/25.
//

import Foundation

struct StockNewsError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? { description }
}

struct StockNewsArticle: Codable, Identifiable {
    var id: String { news_url }

    let news_url: String
    let image_url: String?
    let title: String
    let text: String
    let source_name: String
    let date: String
    let topics: [String]?
    let sentiment: String?
    let type: String?
}

struct StockNewsResponse: Codable {
    let data: [StockNewsArticle]
    let total_pages: Int?
    let total_items: Int?
}

enum StockNewsSection: String, CaseIterable, Identifiable {
    case general
    case forex
    case crypto
    case index
    case commodity
    case economy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .general: return "General"
        case .forex: return "Forex"
        case .crypto: return "Crypto"
        case .index: return "Indices"
        case .commodity: return "Commodities"
        case .economy: return "Economy"
        }
    }
}

enum StockNewsType: String, CaseIterable, Identifiable {
    case all
    case article
    case pr

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: return "All"
        case .article: return "Articles"
        case .pr: return "Press Releases"
        }
    }
}

class StockNewsApiClient {
    static func fetchNews(
        token: String,
        section: StockNewsSection,
        type: StockNewsType,
        items: Int = 10,
        page: Int = 1
    ) async throws -> [StockNewsArticle] {
        guard !token.isEmpty else {
            throw StockNewsError("StockNews API token is missing.")
        }

        var components = URLComponents(string: "https://stocknewsapi.com/api/v1/category")
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "section", value: section.rawValue),
            URLQueryItem(name: "items", value: String(items)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "token", value: token)
        ]
        if type != .all {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw StockNewsError("URL invalid")
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw StockNewsError("HTTP \(http.statusCode): \(body)")
        }

        let decodedResponse = try JSONDecoder().decode(StockNewsResponse.self, from: data)
        return decodedResponse.data
    }
}
