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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { URLSchemeHandler.handle(url: $0) }
        }
        .modelContainer(for: AccountModel.self)
    }
}
