//
//  Shot_of_GreedApp.swift
//  Shot of Greed
//
//  Created by Manith Kha on 30/6/2025.
//

import SwiftUI

@main
struct Shot_of_GreedApp: App {
    @StateObject private var Manager = SessionManager()
    var body: some Scene {
        WindowGroup {
            WrapperView()
                .environmentObject(Manager)
        }
    }
}
