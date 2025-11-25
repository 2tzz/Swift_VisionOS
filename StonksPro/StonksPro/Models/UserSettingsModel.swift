//
//  UserSettingsModel.swift
//  StonksPro
//
//  Created by Peter Graham on 6/25/23.
//

import SwiftUI
import Observation

@Observable class UserSettingsModel {
    var alphaVantageApiKey: String = "2GIZQI8TNR9F628T"
    var useMockStockData: Bool = false
    var coinGeckoApiKey: String = "CG-5aVUR5yNMYpYNKKCSZ4tHTez"
    var stockNewsApiToken: String = "dcd96hk63ej9a4tsjqhbbc3ybuererp5fszr6oji"
}
