//
//  NextSyncApp.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import NextSyncKit
import SwiftData
import SwiftUI

class NextSyncAppState: ObservableObject {
    static let shared = NextSyncAppState()
    let loginWindowId = "loginWindow"
}

@main
struct NextSyncApp: App {
    var container = try! ModelContainer(for: AccountModel.self)
    @StateObject var appState: NextSyncAppState = .shared

    var body: some Scene {
#if os(macOS)
        MenuBarExtra("NextSync", systemImage: "externaldrive.fill.badge.icloud") {
            configured(mainView: StatusBarContentView())
        }
        .menuBarExtraStyle(.window)
#else
        WindowGroup {
            configured(mainView: ContentView())
        }
#endif

        Window("Log in", id: appState.loginWindowId) {
            LoginView(isWindow: true)
        }

        Settings {
            configured(mainView: SettingsView().frame(minWidth: 480, minHeight: 240))
        }
    }

    @ViewBuilder
    func configured(mainView: some View) -> some View {
        mainView
            .modelContainer(container)
            .environmentObject(FileProviderController(modelContainer: container))
            .environmentObject(appState)
            .onOpenURL { URLSchemeHandler.handle(url: $0, container: container) }
    }
}
