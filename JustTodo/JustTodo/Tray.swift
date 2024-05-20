//
//  Tray.swift
//  JustTodo
//
//  Created by Beak on 2024/5/20.
//

import AppKit

class Tray: NSObject, NSPopoverDelegate {
    
    public static let POPOVER_SIZE = NSSize(width: 320, height: 480)
    
    private let iconName: String
    private var statusItem: NSStatusItem!
    private(set) var popover: NSPopover!
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
        viewController.view.nextResponder = viewController
        viewController.view.frame = NSRect(x: 0, y: 0, width: Tray.POPOVER_SIZE.width, height: Tray.POPOVER_SIZE.height)
        
        popover = NSPopover()
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = viewController
        
    }
    
    func popoverDidShow(_ notification: Notification) {
        // 确保 popover 的层级在输入法之下，解决中文输入法浮窗被遮挡问题
        popover.contentViewController?.view.window?.level = .floating
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
