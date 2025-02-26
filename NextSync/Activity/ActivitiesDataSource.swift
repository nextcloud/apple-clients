//
//  ActivitiesDataSource.swift
//  NextSync
//
//  Created by Claudio Cambra on 26/2/25.
//

import NextcloudKit
import NextSyncKit
import OSLog
import SwiftUI

extension NKActivity: @retroactive Identifiable {}

class ActivitiesDataSource: ObservableObject {
    let account: AccountModel
    let activityLimit: Int
    let objectId: String?
    let objectType: String?

    @Published private(set) var activities = [NKActivity]()
    private var latestFetchedActivityId = 0
    private let logger = Logger(subsystem: Logger.subsystem, category: "ActivitiesDataSource")

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

        account.addToNcKitSessions()
    }

    func fetch() async -> NKError {
        logger.info("Retrieving activities for \(self.account.ncKitAccount, privacy: .public)")
        return await withCheckedContinuation { continuation in
            NextcloudKit.shared.getActivity(
                since: latestFetchedActivityId,
                limit: activityLimit,
                objectId: nil,
                objectType: objectType,
                previews: true,
                account: account.ncKitAccount) {
                    _ in // TODO: Task handler?
                } completion: { account, activities, activityFirstKnown, activityLastGiven, _, error in
                    defer { continuation.resume(returning: error) }
                    guard error == .success, account == self.account.ncKitAccount else {
                        self.logger.error(
                            """
                            Unable to retrieve activities, encountered error:
                                \(error.errorDescription, privacy: .public)
                            """
                        )
                        return
                    }
                    self.latestFetchedActivityId = max(activityFirstKnown, activityLastGiven)
                    self.activities = activities + self.activities
                    self.logger.info("Retrieved \(activities.count) activities")
                }
        }
    }
}
