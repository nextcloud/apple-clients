//
//  NSFileProviderDomain+Extensions.swift
//  NextSyncKit
//
//  Created by Claudio Cambra on 21/4/24.
//

import FileProvider
import Foundation

public extension NSFileProviderDomain {
    var rawIdentifier: String { identifier.rawValue }
}
