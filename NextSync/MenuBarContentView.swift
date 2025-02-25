//
//  StatusBarContentView.swift
//  NextSync
//
//  Created by Claudio Cambra on 25/2/25.
//

import NextSyncKit
import SwiftData
import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject var appState: NextSyncAppState
    @Environment(\.modelContext) var modelContext
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

    @State var accountSelection: AccountModel?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                AccountPicker(selection: $accountSelection)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                Button {
                    openWindow(id: appState.loginWindowId)
                } label: {
                    Image(systemName: "person.crop.circle.badge.plus")
                }
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .padding(.all, 8)
        .navigationTitle("NextSync")
        .onAppear {
            guard accountSelection == nil else { return }
            let accounts = try? modelContext.fetch(FetchDescriptor<AccountModel>())
            accountSelection = accounts?.first
        }
    }
}
