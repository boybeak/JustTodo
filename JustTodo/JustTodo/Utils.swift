//
//  Utils.swift
//  JustTodo
//
//  Created by Beak on 2024/5/29.
//

import Foundation

private let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
func randomString(length: Int) -> String {
    return String((0..<length).map { _ in characters.randomElement()! })
}

func copyFilesToSandbox(urls: [URL], subDir: String? = nil, completion: @escaping ([URL]) -> Void) {
    DispatchQueue.global().async {
        let fileManager = FileManager.default
        let sandboxDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let dstDir: URL
        if let subDir = subDir {
            dstDir = sandboxDirectory.appendingPathComponent(subDir)
        } else {
            dstDir = sandboxDirectory
        }

        // 创建目标目录
        do {
            try fileManager.createDirectory(at: dstDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("创建目录失败: \(error)")
            DispatchQueue.main.async {
                completion([])
            }
            return
        }

        var dstUrls: [URL] = []
        for url in urls {
            let fileExtension = url.pathExtension
            let randomFileName = randomString(length: 8) + "." + fileExtension
            let destinationURL = dstDir.appendingPathComponent(randomFileName)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: url, to: destinationURL)
                dstUrls.append(destinationURL)
            } catch {
                print("文件复制失败: \(error)")
            }
        }

        DispatchQueue.main.async {
            completion(dstUrls)
        }
    }
}

func readFilesAsync(from directory: String, completion: @escaping ([URL:Data]) -> Void) {
    DispatchQueue.global().async {
        let fileManager = FileManager.default
        
        do {
            // 获取用户目录
            let userDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryURL = userDirectory.appendingPathComponent(directory)
            
            // 获取目录下的所有文件路径
            var fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
            let fileContents = readFileContents(urls: fileURLs)
            
            // 在主线程中调用回调，返回文件内容数组
            DispatchQueue.main.async {
                completion(fileContents)
            }
        } catch _ {
            // 如果发生错误，则在主线程中调用回调，返回 nil
            DispatchQueue.main.async {
                completion([URL:Data]())
            }
        }
    }
}

func getUrlsAsync(from directory: String) -> [URL]  {
    let fileManager = FileManager.default
    
    do {
        // 获取用户目录
        let userDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryURL = userDirectory.appendingPathComponent(directory)
        
        // 获取目录下的所有文件路径
        var fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        
        return fileURLs
    } catch _ {
        return []
    }
}


func readFileContents(urls: [URL])-> [URL:Data] {
    var fileContents = [URL:Data]()
    for fileURL in urls {
        // 读取文件内容
        if let content = try? Data(contentsOf: fileURL) {
            fileContents[fileURL] = content
        }
    }
    return fileContents
}

func readFileContent(url: URL)-> Data {
    return try! Data(contentsOf: url)
}

func deleteFile(subdirectory: String, filename: String) {
    // 获取沙盒文档目录的路径
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    
    // 构建子目录路径
    let subdirectoryURL = documentsDirectory.appendingPathComponent(subdirectory)
    
    // 构建要删除的文件路径
    let fileURL = subdirectoryURL.appendingPathComponent(filename)
    
    // 检查文件是否存在
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
        return
    }
    
    // 执行文件删除操作
    DispatchQueue.global().async {
        do {
            // 删除文件
            try FileManager.default.removeItem(at: fileURL)
        } catch {
        }
    }
}

func newIconCallback(holder: WKWebViewHolder) -> ([Icon]) -> Void {
    let callback: ([Icon]) -> Void = { icons in
        do {
            let jsonData = try JSONEncoder().encode(icons)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                holder.wkWebView?.jsOnEvent(eventName: "onIconsAdd", message: jsonString)
            }
        } catch {
            
        }
    }
    return callback
}

func mapOf<K, V>(_ pairs: (K, V)...) -> [K: V] {
    return Dictionary(uniqueKeysWithValues: pairs)
}
