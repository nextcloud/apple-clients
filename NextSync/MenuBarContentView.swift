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
    @Environment(\.modelContext) var modelContext

    @State var accountSelection: AccountModel?
    @State var showingNotifications = false

    let contentSpacing = 8.0
    let smallContentSpacing = 2.0
    let contentBorderRadius = 4.0

    var body: some View {
        VStack(spacing: contentSpacing) {
            MenuBarHeaderView(
                accountSelection: $accountSelection,showingNotifications: $showingNotifications
            )
            if let accountSelection {
                ActivityList(account: accountSelection)
                    .listStyle(.plain)
                    .frame(minWidth: 360, minHeight: 400)
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
