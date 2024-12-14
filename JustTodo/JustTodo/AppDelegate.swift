//
//  AppDelegate.swift
//  JustTodo
//
//  Created by Beak on 2024/5/24.
//

import AppKit
import SwiftUI
import Tray
import LaunchAtLogin
import GithubReleaseChecker
import SwiftUIWindow
import Ink

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var tray: Tray!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        tray = Tray.install(named: "TrayIcon") { tray in
            setupMainTray(tray: tray)
        }
        
    }
    
    private func setupMainTray(tray: Tray) {
        tray.setView(content: ContentView(), size: CGSize(width: 320, height: 480))
        let menu = NSMenu()
                
        //        Can not make launch on boot work until now
        let launchBootItem = NSMenuItem(title: NSLocalizedString("menu_item_launch_on_boot", comment: "launch on boot menu item"), action: #selector(actionLaunchOnBoot(_:)), keyEquivalent: "")

        launchBootItem.state = LaunchAtLogin.isEnabled ? .on : .off
        
        launchBootItem.target = self
        menu.addItem(launchBootItem)
        
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: NSLocalizedString("menu_item_version_check", comment: "Check update"), action: #selector(checkUpdate(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: NSLocalizedString("menu_item_about", comment: "About menu item"), action: #selector(actionAbout(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: NSLocalizedString("menu_item_quit", comment: "Quit menu item"), action: #selector(actionQuit(_:)), keyEquivalent: ""))
        tray.setMenu(menu: menu)
    }
    
    @objc func checkUpdate(_ sender: NSMenuItem) {
        let checker = GithubReleaseChecker()

        let alert = self.showLoadingDialog()
        checker.checkUpdate(for: .userRepo("boybeak/JustTodo")) { result in
            DispatchQueue.main.async {
                alert.close()
            }
            switch result {
            case .success(let (newVersion, hasUpdate)):
                if hasUpdate, let releaseInfo = newVersion {
                    self.showUpdateWindow(info: releaseInfo)
                } else {
                    print("当前已经是最新版本")
                }
            case .failure(let error):
                print("检查更新失败：\(error)")
            }
        }
    }
    
    private func showLoadingDialog()-> NSWindow {
        let window = openSwiftUIWindow { win in
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            .frame(width: 100, height: 100)
        }
        
        window.level = .floating
        window.center()
        
        return window
    }
    
    private func showUpdateWindow(info: ReleaseInfo) {
        if let markdown = info.body {
            let parser = MarkdownParser()
            let html = parser.html(from: markdown)
            let window = openSwiftUIWindow { win in
                WebView(html: html)
                    .frame(width: 300, height: 400)
            }
            
            window.center()
        }
        
    }
    
    @objc func actionAbout(_ sender: NSMenuItem) {
        let aboutController = AboutWinController()
        aboutController.showWindow(nil)
    }
    
    @objc func actionLaunchOnBoot(_ sender: NSMenuItem) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        sender.state = LaunchAtLogin.isEnabled ? .on : .off
    }

    @objc func actionQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
    
}
