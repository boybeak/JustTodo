//
//  IconManager.swift
//  JustTodo
//
//  Created by Beak on 2024/5/26.
//

import Foundation
import AppKit

class IconManager {
    static let shared = IconManager()
    
    private static let buildInIcons = [
        "icon-account", "icon-calendar", "icon-chart",
        "icon-movie", "icon-clock", "icon-application",
        "icon-board", "icon-book"
    ]
    
    private let fileURL: URL
    private var cachedIcons: String?
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documentsDirectory.appendingPathComponent("icons.json")
    }
    
    func getBuildInIcons(completion: @escaping ([String]) -> Void) {
        var iconArray: [String] = []
        IconManager.buildInIcons.forEach { iconName in
            if let path = Bundle.main.path(forResource: iconName, ofType: "svg") {
                do {
                    let fileContent = try Data(contentsOf: URL(fileURLWithPath: path))
                    iconArray.append(String(data: fileContent, encoding: .utf8)!)
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
    
    func getCustomIcons(completion: @escaping ([String]) -> Void) {
        readFilesAsync(from: "icons", completion: completion)
    }
    
    func chooseIcon(completion: @escaping ([String]) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.svg]
        panel.allowsMultipleSelection = true
        
        if panel.runModal() == .OK {
            copyFilesToSandbox(urls: panel.urls, subDir: "icons") { urls in
                let contents = readFileContents(urls: urls)
                completion(contents)
            }
        }
    }
    
    func getIcons(completion: @escaping (String?) -> Void) {
        // 如果缓存中有数据，直接返回
        if let cachedIcons = cachedIcons {
            completion(cachedIcons)
            return
        }
        
        // 判断文件是否存在
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // 读取文件内容
                let iconsData = try Data(contentsOf: fileURL)
                let iconsString = String(data: iconsData, encoding: .utf8)
                cachedIcons = iconsString
                completion(iconsString)
            } catch {
                print("Error reading icons file: \(error)")
                completion(nil)
            }
        } else {
            // 文件不存在，下载文件
            downloadIcons { [weak self] result in
                switch result {
                case .success(let iconsString):
                    self?.cachedIcons = iconsString
                    completion(iconsString)
                case .failure(let error):
                    print("Error downloading icons: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    private func downloadIcons(completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/metadata/icons.json")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let iconsString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "IconManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                return
            }
            
            do {
                // 保存下载的文件
                try data.write(to: self.fileURL)
                completion(.success(iconsString))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

