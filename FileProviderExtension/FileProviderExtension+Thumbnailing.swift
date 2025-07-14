//
//  FileProviderExtension+Thumbnailing.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation
import NextcloudFileProviderKit

extension FileProviderExtension: NSFileProviderThumbnailing {
    func fetchThumbnails(
        for itemIdentifiers: [NSFileProviderItemIdentifier],
        requestedSize size: CGSize,
        perThumbnailCompletionHandler: @escaping (
            NSFileProviderItemIdentifier,
            Data?,
            Error?
        ) -> Void,
        completionHandler: @escaping (Error?) -> Void
    ) -> Progress {
        guard let account else {
            logger.error(
                "Unauthenticated, cannot fetch thumbnails. \(itemIdentifiers, privacy: .public)"
            )
            completionHandler(NSFileProviderError(.notAuthenticated))
            return Progress()
        }
        guard let dbManager else {
            completionHandler(NSFileProviderError(.cannotSynchronize))
            return Progress()
        }

        return NextcloudFileProviderKit.fetchThumbnails(
            for: itemIdentifiers,
            requestedSize: size,
            account: account,
            usingRemoteInterface: ncKit,
            andDatabase: dbManager,
            perThumbnailCompletionHandler: perThumbnailCompletionHandler,
            completionHandler: completionHandler
        )
    }
}
