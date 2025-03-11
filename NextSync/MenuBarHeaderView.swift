//
//  MenuBarHeaderView.swift
//  NextSync
//
//  Created by Claudio Cambra on 11/3/25.
//

import NextSyncKit
import SwiftUI

struct MenuBarHeaderView: View {
    @EnvironmentObject var appState: NextSyncAppState
    @Environment(\.openSettings) private var openSettings
    @Environment(\.openWindow) private var openWindow

    @Binding var accountSelection: AccountModel?
    @Binding var showingNotifications: Bool

    // TODO: Move me elsewhere
    let contentSpacing = 8.0
    let smallContentSpacing = 2.0
    let contentBorderRadius = 4.0

    var body: some View {
        HStack(spacing: contentSpacing) {
            HStack(spacing: smallContentSpacing) {
                AccountPicker(selection: $accountSelection)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)

                Button {
                    openWindow(id: appState.loginWindowId)
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                }
            }

            HStack(spacing: smallContentSpacing) {
                Button {
                    showingNotifications.toggle()
                } label: {
                    Image(systemName: "bell.fill")
                }
                .popover(isPresented: $showingNotifications) {
                    if let accountSelection {
                        NotificationsList(account: accountSelection)
                            .frame(minHeight: 250)
                    }
                }

                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gear")
                }

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power.circle")
                }
            }
        }
    }
}
