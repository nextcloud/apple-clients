//
//  StatusBarContentView.swift
//  NextSync
//
//  Created by Claudio Cambra on 25/2/25.
//

import NextSyncKit
import SwiftUI

struct StatusBarContentView: View {
    @EnvironmentObject var appState: NextSyncAppState
    @Environment(\.openWindow) private var openWindow

    @State var accountSelection: AccountModel?

    var body: some View {
        VStack {
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
        .navigationTitle("NextSync")
    }
}
