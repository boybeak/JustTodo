//
//  AboutWindow.swift
//  JustTodo
//
//  Created by Beak on 2024/5/25.
//

import Cocoa
import SwiftUI

class AboutWinController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 640),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered, defer: false)
        window.title = NSLocalizedString("menu_item_about", comment: "About menu item")
        window.center()
        window.level = .floating
        
        let contentView = NSHostingView(rootView: AboutView())
        window.contentView = contentView
        
        self.init(window: window)
    }
}
