//
//  StonksProApp.swift
//  StonksPro
//
//  Created by Peter Graham on 6/25/23.
//

import SwiftUI

@main
struct StockStatApp: App {
    @Bindable var userSettings: UserSettingsModel = UserSettingsModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                StonksView(userSettings: userSettings)
                    .tabItem {
                        Label("Stonks", systemImage: "chart.line.uptrend.xyaxis")
                    }
                GeneralNewsView()
                    .tabItem {
                        Label("Trending News", systemImage: "star.fill")
                    }
                NewsView(userSettings: userSettings)
                    .tabItem {
                        Label("Market News", systemImage: "newspaper")
                    }
                SettingsView(userSettings: userSettings)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
