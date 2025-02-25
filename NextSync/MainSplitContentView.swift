//
//  MainSplitContentView.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation
import NextSyncKit
import SwiftData
import SwiftUI

struct MainSplitContentView: View {
    @Environment(\.modelContext) var modelContext
    @State var sidebarSelection: MainSidebar.Panel?
    @State var accountSelection: AccountModel?

    var body: some View {
        NavigationSplitView {
            MainSidebar(selection: $sidebarSelection, accountSelection: $accountSelection)
                .onAppear {
                    guard accountSelection == nil else { return }
                    let fetchDescriptor = FetchDescriptor<AccountModel>()
                    let accounts = try? modelContext.fetch(fetchDescriptor)
                    accounts?.forEach { print($0.description) }
                    accountSelection = accounts?.first
                }
                .navigationSplitViewColumnWidth(ideal: 200)
        } detail: {
            NavigationStack {
                MainDetailView(selection: $sidebarSelection, accountSelection: $accountSelection)
            }
        }
    }
}
