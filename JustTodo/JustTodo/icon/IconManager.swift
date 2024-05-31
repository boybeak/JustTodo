//
//  IconManager.swift
//  JustTodo
//
//  Created by Beak on 2024/5/26.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

class IconManager {
    static let shared = IconManager()
    
    private static let buildInIcons = [
        "icon-account", "icon-calendar", "icon-chart",
        "icon-movie", "icon-clock", "icon-application",
        "icon-board", "icon-book"
    ]
    
    private class CallbackWrapper {
        let id: UUID
        let callback: ([Icon]) -> Void

        init(id: UUID = UUID(), callback: @escaping ([Icon]) -> Void) {
            self.id = id
            self.callback = callback
        }
    }

    private var callbacks = [CallbackWrapper]()
    
    func addCallback(callback: @escaping ([Icon]) -> Void) -> UUID {
        let wrapper = CallbackWrapper(callback: callback)
        callbacks.append(wrapper)
        return wrapper.id
    }
    
    func removeCallback(id: UUID) {
        callbacks.removeAll { $0.id == id }
    }

    func notifyCallbacks(icons: [Icon]) {
        for wrapper in callbacks {
            wrapper.callback(icons)
        }
    }
    
    func getBuildInIcons(completion: @escaping ([Icon]) -> Void) {
        var iconArray: [Icon] = []
        IconManager.buildInIcons.forEach { iconName in
            if let path = Bundle.main.path(forResource: iconName, ofType: "svg") {
                do {
                    let fileContent = try Data(contentsOf: URL(fileURLWithPath: path))
                    iconArray.append(Icon(iconId: iconName, svgData: fileContent, createDate: Date()))
                    // 处理 fileContent
                } catch {
                    // 处理错误
                    print("Error reading file: \(error.localizedDescription)")
                }
            } else {
                print("File not found for icon: \(iconName)")
            }
        }
        completion(iconArray)
    }
    
    func getCustomIcons(completion: @escaping ([Icon]) -> Void) {
        DispatchQueue.global().async {
            let urls = getUrlsAsync(from: "icons")
            var icons = [Icon]()
            urls.forEach { url in
                icons.append(Icon(url: url))
            }
            icons.sort()
            DispatchQueue.main.async {
                completion(icons)
            }
        }
    }
    
    func addIcons(urls: [URL]) {
        copyFilesToSandbox(urls: urls, subDir: "icons") { iconUrls in
            var icons = [Icon]()
            iconUrls.forEach { iconUrl in
                icons.append(Icon(url: iconUrl))
            }
            self.callbacks.forEach { wrapper in
                wrapper.callback(icons)
            }
        }
    }
    
    func deleteIcon(iconId: String) {
        deleteFile(subdirectory: "icons", filename: iconId)
    }
    
    func openIconsWindow() {
        IconWinController().showWindow(nil)
    }
    
    func openSvgChooser() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true
        openPanel.allowedContentTypes = [.svg]
        openPanel.level = .modalPanel
        
        openPanel.begin { response in
            if response == .OK {
                let selectedFiles = openPanel.urls
                if !selectedFiles.isEmpty {
                    self.addIcons(urls: selectedFiles)
                }
            }
        }
    }
    
}
