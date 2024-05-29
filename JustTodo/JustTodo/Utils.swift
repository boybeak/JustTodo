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
    let fileManager = FileManager.default
    let sandboxDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    let dstDir = if subDir == nil {
        sandboxDirectory
    } else {
        sandboxDirectory.appendingPathComponent(subDir!)
    }

    // 创建 icons 目录
    do {
        try fileManager.createDirectory(at: dstDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("创建 icons 目录失败: \(error)")
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
    completion(dstUrls)
}

func readFilesAsync(from directory: String, completion: @escaping ([String]) -> Void) {
    DispatchQueue.global().async {
        let fileManager = FileManager.default
        
        do {
            // 获取用户目录
            let userDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            let directoryURL = userDirectory.appendingPathComponent(directory)
            
            // 获取目录下的所有文件路径
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
            let fileContents = readFileContents(urls: fileURLs)
            
            // 在主线程中调用回调，返回文件内容数组
            DispatchQueue.main.async {
                completion(fileContents)
            }
        } catch {
            // 如果发生错误，则在主线程中调用回调，返回 nil
            DispatchQueue.main.async {
                completion([])
            }
        }
    }
}


func readFileContents(urls: [URL])-> [String] {
    var fileContents: [String] = []
    for fileURL in urls {
        // 读取文件内容
        if let content = try? String(contentsOf: fileURL, encoding: .utf8) {
            fileContents.append(content)
        }
    }
    return fileContents
}
