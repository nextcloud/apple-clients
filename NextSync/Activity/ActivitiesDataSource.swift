//
//  ActivitiesDataSource.swift
//  NextSync
//
//  Created by Claudio Cambra on 26/2/25.
//

import NextcloudKit
import NextSyncKit
class ActivitiesDataSource: ObservableObject {
    let account: AccountModel
    let activityLimit: Int
    let objectId: String?
    let objectType: String?
    required init(
        account: AccountModel,
        activityLimit: Int = 50,
        objectId: String? = nil,
        objectType: String? = nil
    ) {
        self.account = account
        self.activityLimit = activityLimit
        self.objectId = objectId
        self.objectType = objectType

    }
}
