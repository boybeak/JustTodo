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
        let menu = NSMenu()
                
        //        Can not make launch on boot work until now
        //        let launchBootItem = NSMenuItem(title: NSLocalizedString("menu_item_launch_on_boot", comment: "launch on boot menu item"), action: #selector(actionLaunchOnBoot(_:)), keyEquivalent: "")
        //
        //        launchBootItem.state = if bootLauncher.isLaunchAgentEnabled() {
        //            .on
        //        } else {
        //            .off
        //        }
        //        launchBootItem.target = self
        //        menu.addItem(launchBootItem)
                
        //        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("menu_item_about", comment: "About menu item"), action: #selector(actionAbout(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: NSLocalizedString("menu_item_quit", comment: "Quit menu item"), action: #selector(actionQuit(_:)), keyEquivalent: ""))
        tray.install(icon: NSImage(named: "TrayIcon")!, view: ContentView(), menu: menu)
    }
    
    @objc func actionAbout(_ sender: NSMenuItem) {
        let aboutController = AboutWinController()
        aboutController.showWindow(nil)
    }

    @objc func actionQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
    
}
