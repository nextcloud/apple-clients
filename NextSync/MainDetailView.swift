//
//  MainDetailView.swift
//  NextSync
//
//  Created by Claudio Cambra on 20/4/24.
//

import Foundation
import NextSyncKit
import SwiftUI

struct MainDetailView: View {
    @Binding var selection: MainSidebar.Panel?
    @Binding var accountSelection: AccountModel?

    var body: some View {
        List(selection: $selection) {
            switch selection ?? .files {
            case .files:
                EmptyView()
            case .photos:
                EmptyView()
            case .settings:
                EmptyView()
            }
        }
    }
}
