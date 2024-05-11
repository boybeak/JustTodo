//
//  AppDelegate.swift
//  MyTodo
//
//  Created by Beak on 2024/5/11.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let tray = Tray(iconName: "book.pages.fill", viewController: ViewController())
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        tray.install()
    }
    
}

class Tray {
    
    public static let POPOVER_SIZE = NSSize(width: 320, height: 400)
    
    private let iconName: String
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var viewController: NSViewController
    
    init(iconName: String, viewController: NSViewController) {
        self.iconName = iconName
        self.viewController = viewController
    }
    
    func install() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let trayBtn: NSStatusBarButton = statusItem.button {
            trayBtn.image = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
            
            trayBtn.target = self;
            trayBtn.action = #selector(togglePopover(_:))
        }
        
        viewController.loadViewIfNeeded()
        viewController.view.frame = NSRect(x: 0, y: 0, width: Tray.POPOVER_SIZE.width, height: Tray.POPOVER_SIZE.height)
        
        popover = NSPopover()
        popover.contentViewController = viewController
//        popover.contentSize = NSSize(width: Tray.POPOVER_SIZE.width, height: Tray.POPOVER_SIZE.height)
        
    }
    
    @objc private func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }

    private func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }

    private func closePopover(sender: Any?) {
        popover.performClose(sender)
    }
    
}
