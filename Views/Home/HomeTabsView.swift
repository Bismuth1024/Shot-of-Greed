//
//  HomeTabsView.swift
//  Fwaeh
//
//  Created by Manith Kha on 23/1/2025.
//

import SwiftUI

struct HomeTabsView: View {
    var body: some View {
        TabView {
            SessionView()
                .tabItem {
                    Label("Session", systemImage: "wineglass")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    HomeTabsView()
}

