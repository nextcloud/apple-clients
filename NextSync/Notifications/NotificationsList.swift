//
//  NotificationsList.swift
//  NextSync
//
//  Created by Claudio Cambra on 27/2/25.
//

import NextSyncKit
import SwiftUI

struct NotificationsList: View {
    let account: AccountModel
    var dataSource: NotificationsDataSource
    @State var now = Date()

    init(account: AccountModel) {
        self.account = account
        self.dataSource = NotificationsDataSource(account: account)
    }

    var body: some View {
        ZStack {
            if (dataSource.notifications.isEmpty && dataSource.loading) {
                ProgressView()
                    .frame(alignment: .center)
            }
            List {
                ForEach(dataSource.notifications) { notification in
                    Text(notification.subject)
                }
            }
        }
        .task { await dataSource.fetch() }
    }
}
