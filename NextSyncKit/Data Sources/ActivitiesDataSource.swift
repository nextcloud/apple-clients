//
//  ActivitiesDataSource.swift
//  NextSync
//
//  Created by Claudio Cambra on 26/2/25.
//

import NextcloudKit
import OSLog
import SwiftyJSON
import SwiftUI

extension NKActivity: @retroactive Identifiable {}

@Observable
public class ActivitiesDataSource {
    public let account: AccountModel
    public let activityLimit: Int
    public let objectId: String?
    public let objectType: String?
    public let previewSize: CGFloat

    private(set) public var activities = [NKActivity]() {
        didSet {
            activities.forEach { activity in
                Task {
                    if let image = await preview(for: activity) {
                        Task { @MainActor in
                            previews[activity.idActivity] = image
                        }
                    }
                }
            }
        }
    }
    private(set) public var previews = [Int: Image]()
    private(set) public var loading = false

    private var latestFetchedActivityId = 0
    private let logger = Logger(subsystem: Logger.subsystem, category: "ActivitiesDataSource")

    required public init(
        account: AccountModel,
        activityLimit: Int = 50,
        objectId: String? = nil,
        objectType: String? = nil,
        previewSize: CGFloat = 32
    ) {
        self.account = account
        self.activityLimit = activityLimit
        self.objectId = objectId
        self.objectType = objectType
        self.previewSize = previewSize

        account.addToNcKitSessions()
    }

    @discardableResult public func preview(for activity: NKActivity) async -> Image? {
        guard previews[activity.idActivity] == nil else {
            logger.debug("Not fetching preview for \(activity.idActivity), already acquired")
            return previews[activity.idActivity]
        }

        guard let previewsRaw = activity.previews,
              let previewsJson = JSON(previewsRaw).array,
              let previewJson = previewsJson.first,
              let fileId = previewJson["fileId"].int
        else {
            logger.error(
                """
                Activity \(activity) did not have valid previews:
                    \(String(data: activity.previews ?? Data(), encoding: .utf8) ?? "NULL")
                """
            )
            return nil
        }

        return await withCheckedContinuation { continuation in
            logger.debug("Getting preview for activity with fileId: \(fileId)")
            NextcloudKit.shared.downloadPreview(
                fileId: String(fileId),
                width: Int(previewSize),
                height: Int(previewSize),
                account: account.ncKitAccount
            ) { _, _, _, _, responseData, error in
                guard error == .success else {
                    self.logger.error(
                        """
                        Could not retrieve preview for activity with fileId \(fileId).
                            Received error: \(error.errorDescription, privacy: .public)
                        """
                    )
                    continuation.resume(returning: nil)
                    return
                }

                guard let data = responseData?.data else {
                    self.logger.error("Could not acquire image data.")
                    continuation.resume(returning: nil)
                    return
                }

                #if os(macOS)
                let platformImage = NSImage(data: data)
                #else
                let platformimage = UIImage(data: data)
                #endif
                guard let platformImage else {
                    self.logger.error("Could not create preview platform image.")
                    continuation.resume(returning: nil)
                    return
                }

                #if os(macOS)
                continuation.resume(returning: Image(nsImage: platformImage))
                #else
                continuation.resume(returning: Image(uiImage: platformImage))
                #endif
                self.logger.info("Got preview for activity with fileId: \(fileId)")
            }
        }
    }

    @discardableResult public func fetch() async -> NKError {
        loading = true
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
                    self.loading = false
                    self.logger.info("Retrieved \(activities.count) activities")
                }
        }
    }
}
