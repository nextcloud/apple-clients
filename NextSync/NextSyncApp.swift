//
//  NextSyncApp.swift
//  NextSync
//
//  Created by Claudio Cambra on 19/4/24.
//

import SwiftData
import SwiftUI

@main
struct NextSyncApp: App {
    var container = try! ModelContainer(for: AccountModel.self)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { URLSchemeHandler.handle(url: $0, container: container) }
        }
        .modelContainer(container)
    }
}
