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
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered, defer: false)
        window.title = "New Window"
        window.center()
        window.level = .floating
        
        let contentView = NSHostingView(rootView: AboutView())
        window.contentView = contentView
        
        self.init(window: window)
    }
}
