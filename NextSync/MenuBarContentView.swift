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

    var body: some View {
        VStack(spacing: Measurements.spacing) {
            MenuBarHeaderView(
                accountSelection: $accountSelection,showingNotifications: $showingNotifications
            )
            if let accountSelection {
                ActivityList(account: accountSelection)
                    .listStyle(.plain)
                    .frame(minWidth: 360, minHeight: 400)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Measurements.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: Measurements.cornerRadius)
                            .stroke(.separator, lineWidth: Measurements.separatorWidth)
                    )
            }
        }
        .padding(.all, Measurements.spacing)
        .navigationTitle("NextSync")
        .onAppear {
            guard accountSelection == nil else { return }
            let accounts = try? modelContext.fetch(FetchDescriptor<AccountModel>())
            accountSelection = accounts?.first
        }
    }
}
