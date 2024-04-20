//
//  FileProviderExtension+Servicing.swift
//  FileProviderExtension
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation

extension FileProviderExtension: NSFileProviderServicing {
    func supportedServiceSources(
        for itemIdentifier: NSFileProviderItemIdentifier,
        completionHandler: @escaping ([any NSFileProviderServiceSource]?, (any Error)?) -> Void
    ) -> Progress {
        completionHandler([], nil)
        return Progress()
    }
}
