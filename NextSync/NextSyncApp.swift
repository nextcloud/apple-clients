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
    let loginWindowId = "loginWindow"
}

@main
struct NextSyncApp: App {
    var container = try! ModelContainer(for: AccountModel.self)
    @StateObject var appState = NextSyncAppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { URLSchemeHandler.handle(url: $0, container: container) }
        }
        .modelContainer(container)
        .environmentObject(FileProviderController(modelContainer: container))
        .environmentObject(appState)

        Window("Log in", id: appState.loginWindowId) {
            LoginView(isWindow: true)
        }
    }
}
