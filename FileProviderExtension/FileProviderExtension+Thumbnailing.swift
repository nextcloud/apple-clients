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
        return NextcloudFileProviderKit.fetchThumbnails(
            for: itemIdentifiers,
            requestedSize: size,
            usingKit: self.ncKit,
            perThumbnailCompletionHandler: perThumbnailCompletionHandler,
            completionHandler: completionHandler
        )
    }
}
