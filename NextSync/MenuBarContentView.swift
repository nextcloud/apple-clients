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

    let contentSpacing = 8.0
    let contentBorderRadius = 4.0

    var body: some View {
        VStack(spacing: contentSpacing) {
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
            if let accountSelection {
                ActivityList(account: accountSelection)
                    .listStyle(.plain)
                    .frame(minHeight: 400)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: contentBorderRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: contentBorderRadius)
                            .stroke(.separator, lineWidth: 1)
                    )
            }
        }
        .padding(.all, contentSpacing)
        .navigationTitle("NextSync")
        .onAppear {
            guard accountSelection == nil else { return }
            let accounts = try? modelContext.fetch(FetchDescriptor<AccountModel>())
            accountSelection = accounts?.first
        }
    }
}
