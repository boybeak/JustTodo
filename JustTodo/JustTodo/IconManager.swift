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
    
    func getBuildInIcons(completion: @escaping ([Icon]) -> Void) {
        var iconArray: [Icon] = []
        IconManager.buildInIcons.forEach { iconName in
            if let path = Bundle.main.path(forResource: iconName, ofType: "svg") {
                do {
                    let fileContent = try Data(contentsOf: URL(fileURLWithPath: path))
                    iconArray.append(Icon(iconId: iconName, svgData: fileContent))
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
        readFilesAsync(from: "icons") { result in
            var icons = [Icon]()
            result.forEach { url, content in
                icons.append(Icon(iconId: url.lastPathComponent, svgData: content))
            }
            completion(icons)
        }
    }
    
    func chooseIcon(view: NSView, completion: @escaping ([Icon]) -> Void) {
        
        /*
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.svg]
        panel.allowsMultipleSelection = true
        
        if let window = view.window {
            // 在主窗口上展示文件选择对话框
            window.beginSheet(panel) { response in
                if response == .OK {
                    copyFilesToSandbox(urls: panel.urls, subDir: "icons") { urls in
                        DispatchQueue.global().async {
                            var icons = [Icon]()
                            urls.forEach { url in
                                icons.append(Icon(iconId: url.lastPathComponent, svgData: readFileContent(url: url)))
                            }
                            
                            DispatchQueue.main.async {
                                completion(icons)
                            }
                        }
                        
                    }
                }
            }
        }
//        if panel.runModal() == .OK {
//            copyFilesToSandbox(urls: panel.urls, subDir: "icons") { urls in
//                DispatchQueue.global().async {
//                    var icons = [Icon]()
//                    urls.forEach { url in
//                        icons.append(Icon(iconId: url.lastPathComponent, svgData: readFileContent(url: url)))
//                    }
//                    
//                    DispatchQueue.main.async {
//                        completion(icons)
//                    }
//                }
//                
//            }
//        }
         */
    }
    
    func deleteIcon(iconId: String) {
        deleteFile(subdirectory: "icons", filename: iconId)
    }
    
}

