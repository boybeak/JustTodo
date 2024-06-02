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

    private var callbacks = [IconCallback]()
    
    func addCallback(callback: IconCallback) -> UUID {
        callbacks.append(callback)
        return callback.id
    }
    
    func removeCallback(id: UUID) {
        callbacks.removeAll { $0.id == id }
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
        
            self.callbacks.forEach { callback in
                callback.onIconsAdded(icons: icons)
            }
        }
    }
    
    func deleteIcon(iconId: String) {
        deleteFile(subdirectory: "icons", filename: iconId)
        self.callbacks.forEach { callback in
            callback.onIconRemoved(iconId: iconId)
        }
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

struct IconCallback {
    
    let id = UUID()
    private let onIconsAddedHandler: ([Icon]) -> Void
    private let onIconRemovedHandler: (String) -> Void
    
    init(onIconsAdded: @escaping ([Icon]) -> Void, onIconRemoved: @escaping (String) -> Void) {
        self.onIconsAddedHandler = onIconsAdded
        self.onIconRemovedHandler = onIconRemoved
    }
    
    func onIconsAdded(icons: [Icon]) {
        self.onIconsAddedHandler(icons)
    }
    
    func onIconRemoved(iconId: String) {
        self.onIconRemovedHandler(iconId)
    }
    
}
