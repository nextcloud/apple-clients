//
//  ActivityList.swift
//  NextSync
//
//  Created by Claudio Cambra on 26/2/25.
//

import NextcloudKit
import NextSyncKit
import SwiftUI

struct ActivityList: View {
    let account: AccountModel
    @ObservedObject var dataSource: ActivitiesDataSource

    init(account: AccountModel) {
        self.account = account
        self.dataSource = ActivitiesDataSource(account: account)
    }

    var body: some View {
        List {
            ForEach(dataSource.activities) { activity in
                Text(activity.subject)
                }
            }
        }
        .border(.separator)
        .onAppear {
            Task { await dataSource.fetch() }
        }
    }
}
