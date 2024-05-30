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
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
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
