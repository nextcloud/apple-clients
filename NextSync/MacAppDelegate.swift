//
//  AppDelegate.swift
//  NextSync
//
//  Created by Claudio Cambra on 25/2/25.
//

import AppKit
import SwiftUI

class MacAppDelegate: NSObject, NSApplicationDelegate {
    let popover = NSPopover()
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: StatusBarContentView()
        )

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem?.button {
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.image = NSImage( // TODO: Use a proper icon!
                systemSymbolName: "externaldrive.fill.badge.icloud",accessibilityDescription: "Icon"
            )
        }
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.minY)
        }
    }
}
