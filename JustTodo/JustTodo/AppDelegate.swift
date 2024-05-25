//
//  AppDelegate.swift
//  JustTodo
//
//  Created by Beak on 2024/5/24.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let tray = Tray()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMainTray()
    }
    
    private func setupMainTray() {
        let menu = NSMenu(title: "Translator")
        let aboutMenuItem = NSMenuItem(title: "About", action: #selector(menuItemAbout), keyEquivalent: "")
        aboutMenuItem.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: nil)
        menu.addItem(aboutMenuItem)
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(menuItemQuit), keyEquivalent: "")
        quitMenuItem.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
        menu.addItem(quitMenuItem)
        tray.install(icon: NSImage(named: "TrayIcon")!, view: ContentView(), menu: menu)
    }
    
    @objc func menuItemAbout() {
        NSApp.sendAction(#selector(AppDelegate.doOpenAboutWindow), to: nil, from:nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    @objc func doOpenAboutWindow() {
        
    }
    @objc func menuItemSettings() {
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    @objc func menuItemQuit() {
        NSApplication.shared.terminate(nil)
    }
    
}
