//
//  AboutWindow.swift
//  JustTodo
//
//  Created by Beak on 2024/5/21.
//

import AppKit
import WebKit

class AboutWindow: NSWindow, NSWindowDelegate {
    
    private static var isShowing = false
    
    static func show() {
        if (isShowing) {
            return
        }
        let win = AboutWindow()
        
        win.center()
        let winController = NSWindowController(window: win)
        
        winController.showWindow(nil)
        win.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        isShowing = true
    }
    
    private var aboutController: WebViewController?
    
    private init() {
        super.init(contentRect: NSMakeRect(0, 0, 400, 300), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        afterInit()
    }
    
    private override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        afterInit()
    }
    
    private func afterInit() {
        self.title = NSLocalizedString("menu_item_about", comment: "About window title")
        self.delegate = self
        
        aboutController = WebViewController()
        self.contentViewController = aboutController
        aboutController?.load(page: "about")
    }
    
    func windowWillClose(_ notification: Notification) {
        AboutWindow.isShowing = false
    }
    
}
