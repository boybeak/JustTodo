//
//  Tray.swift
//  JustTodo
//
//  Created by Beak on 2024/5/25.
//

import AppKit
import SwiftUI

class Tray: NSObject, NSPopoverDelegate {
    @Published var statusItem: NSStatusItem?
    @Published var popover = NSPopover()
    
    private var rightMenu: NSMenu? = nil
    
    func install(icon: NSImage, view: any View, menu: NSMenu? = nil) {
        self.rightMenu = menu
        
        popover.animates = true
        popover.behavior = .transient
        popover.delegate = self
        
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: ContentView())
        popover.contentViewController?.view.frame = NSRect(x: 0, y: 0, width: 320, height: 480)
        popover.contentViewController?.view.window?.makeKey()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//        statusItem?.menu = menu
        if let menuBtn = statusItem?.button {
            icon.isTemplate = true
            menuBtn.image = icon
            menuBtn.target = self
            menuBtn.action = #selector(menuBtnAction)
            menuBtn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    func popoverDidShow(_ notification: Notification) {
        popover.contentViewController?.view.window?.level = .floating
    }
    
    @objc func menuBtnAction(sender: AnyObject) {
        guard let event = NSApp.currentEvent else { return }
        switch event.type {
        case .rightMouseUp:
            if rightMenu != nil {
                statusItem?.popUpMenu(rightMenu!)
            } else {
                togglePopover(sender: sender)
            }
        default:
            togglePopover(sender: sender)
        }
    }
    
    private func togglePopover(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let menuBtn = statusItem?.button {
                popover.show(relativeTo: menuBtn.bounds, of: menuBtn, preferredEdge: .minY)
            }
        }
    }
    
}
