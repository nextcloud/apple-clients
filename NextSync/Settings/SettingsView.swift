//
//  SettingsView.swift
//  NextSync
//
//  Created by Claudio Cambra on 25/2/25.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case accounts, general, network
    }

    var body: some View {
        TabView {
            VStack {}
                .tabItem {
                    labelForTab(.accounts)
                }
                .tag(Tabs.accounts)
            VStack {}
                .tabItem {
                    labelForTab(.general)
                }
                .tag(Tabs.general)
            VStack {}
                .tabItem {
                    labelForTab(.network)
                }
                .tag(Tabs.network)
        }
    }

    private func labelForTab(_ tab: Tabs) -> some View {
        switch tab {
        case .accounts:
            Label("Accounts", systemImage: "person.crop.circle")
        case .general:
            Label("General", systemImage: "gear")
        case .network:
            Label("Network", systemImage: "network")
        }
    }
}
