//
//  BootLauncher.swift
//  JustTodo
//
//  Created by Beak on 2024/5/23.
//

import Foundation
import Security

class BootLauncher {
    func createAndLoadLaunchAgent() {
        let fileManager = FileManager.default
        let launchAgentsPath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library").appendingPathComponent("LaunchAgents")
        let plistPath = launchAgentsPath.appendingPathComponent("com.github.boybeak.JustTodo.plist")
        let appPath = Bundle.main.bundlePath

        let plistContent: [String: Any] = [
            "Label": "com.github.boybeak.JustTodo",
            "ProgramArguments": [appPath + "/Contents/MacOS/JustTodo"], // 确保这是你的可执行文件路径
            "RunAtLoad": true
        ]

        do {
            if !fileManager.fileExists(atPath: launchAgentsPath.path) {
                try fileManager.createDirectory(at: launchAgentsPath, withIntermediateDirectories: true, attributes: nil)
            }
            let plistData = try PropertyListSerialization.data(fromPropertyList: plistContent, format: .xml, options: 0)
            try plistData.write(to: plistPath)
            print("Launch agent created successfully at \(plistPath)")

            // 加载启动项
            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["load", plistPath.path]
            try task.run()
            print("Launch agent loaded successfully")
        } catch {
            print("Failed to create or load launch agent: \(error)")
        }
    }

    func unloadAndDeleteLaunchAgent() {
        let fileManager = FileManager.default
        let launchAgentsPath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library").appendingPathComponent("LaunchAgents")
        let plistPath = launchAgentsPath.appendingPathComponent("com.github.boybeak.JustTodo.plist")

        do {
            if fileManager.fileExists(atPath: plistPath.path) {
                // 卸载启动项
                let task = Process()
                task.launchPath = "/bin/launchctl"
                task.arguments = ["unload", plistPath.path]
                try task.run()
                print("Launch agent unloaded successfully")

                // 删除启动项文件
                try fileManager.removeItem(at: plistPath)
                print("Launch agent removed successfully from \(plistPath)")
            } else {
                print("Launch agent not found at \(plistPath)")
            }
        } catch {
            print("Failed to unload or remove launch agent: \(error)")
        }
    }

    func isLaunchAgentEnabled() -> Bool {
        let fileManager = FileManager.default
        let launchAgentsPath = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library").appendingPathComponent("LaunchAgents")
        let plistPath = launchAgentsPath.appendingPathComponent("com.github.boybeak.JustTodo.plist")
        return fileManager.fileExists(atPath: plistPath.path)
        
//        return false
    }

}
