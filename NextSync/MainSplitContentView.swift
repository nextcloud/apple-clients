//
//  MainSplitContentView.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation
import SwiftUI

struct MainSplitContentView: View {
    @State var sidebarSelection: MainSidebar.Panel?
    @State var accountSelection: AccountModel?

    var body: some View {
        NavigationSplitView {
            MainSidebar(selection: $sidebarSelection, accountSelection: $accountSelection)
        } detail: {
            NavigationStack {
                MainDetailView(selection: $sidebarSelection)
            }
        }
    }
}
