//
//  NotificationsDataSource.swift
//  NextSync
//
//  Created by Claudio Cambra on 27/2/25.
//

import NextcloudKit
import OSLog
import SwiftUI

extension NKNotifications: @retroactive Identifiable {}

@Observable
public class NotificationsDataSource {
    public let account: AccountModel
    private(set) public var notifications = [NKNotifications]()
    private(set) public var loading = false
    private let logger = Logger(subsystem: Logger.subsystem, category: "NotificationsDataSource")

    required public init(account: AccountModel) {
        self.account = account
        account.addToNcKitSessions()
    }

    @discardableResult public func fetch() async -> NKError {
        loading = true

        return await withCheckedContinuation { continuation in
            NextcloudKit.shared.getNotifications(
                account: account.ncKitAccount
            ) { account, receivedNotifications, responseData, error in
                defer { continuation.resume(returning: error) }
                guard error == .success,
                      account == self.account.ncKitAccount,
                      let receivedNotifications
                else {
                    self.logger.error(
                        """
                        Unable to retrieve notifications, encountered error:
                            \(error.errorDescription, privacy: .public)
                        """
                    )
                    return
                }
                self.notifications = receivedNotifications
                self.loading = false
            }
        }
    }
}
