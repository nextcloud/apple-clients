//
//  MainSidebar.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation
import NextSyncKit
import SwiftUI

struct MainSidebar: View {
    enum Panel {
        case files, photos, settings
    }

    @EnvironmentObject var appState: NextSyncAppState
    @Environment(\.openWindow) private var openWindow

    @Binding var selection: Panel?
    @Binding var accountSelection: AccountModel?

    var body: some View {
        List(selection: $selection) {
            NavigationLink(value: Panel.files) {
                Label("Files", systemImage: "folder")
            }
            NavigationLink(value: Panel.photos) {
                Label("Photos", systemImage: "photo.stack")
            }
            NavigationLink(value: Panel.settings) {
                Label("Settings", systemImage: "gear")
            }

            Section("Accounts") {
                HStack {
                    AccountPicker(selection: $accountSelection)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    Button {
                        openWindow(id: appState.loginWindowId)
                    } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
        .navigationTitle("NextSync")
    }
}
