//
//  AppDelegate.swift
//  NextSync
//
//  Created by Claudio Cambra on 25/2/25.
//

import AppKit

class MacAppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
    }
}
