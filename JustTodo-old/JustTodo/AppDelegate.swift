//
//  AppDelegate.swift
//  JustTodo
//
//  Created by Beak on 2024/5/20.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    private let tray = Tray(iconName: "TrayIcon", viewController: ViewController())
    
    private var aboutWindowController: NSWindowController?
    
    private let bootLauncher = BootLauncher()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
        tray.install(menu: menu)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func actionLaunchOnBoot(_ sender: NSMenuItem) {
        if (sender.state == .on) {
            sender.state = .off
            bootLauncher.unloadAndDeleteLaunchAgent()
        } else {
            sender.state = .on
            bootLauncher.createAndLoadLaunchAgent()
        }
    }
    
    @objc func actionAbout(_ sender: NSMenuItem) {
//        showAboutWindow()
        AboutWindow.show()
    }
    
    @objc func actionQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    private func printErrorWithCallStack(_ error: Error) {
        NSLog("Error: \(error.localizedDescription)")
        NSLog("Call Stack:")
        for symbol in Thread.callStackSymbols {
            NSLog(symbol)
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        TodoDB.shared.onAppTerminate()
        
        return .terminateNow
    }
}
