//
//  Icon.swift
//  JustTodo
//
//  Created by Beak on 2024/5/30.
//

import Foundation

class Icon: Codable, Comparable {
    
    // 实现 Equatable 协议
    static func == (lhs: Icon, rhs: Icon) -> Bool {
        return lhs.iconId == rhs.iconId
    }
    
    // 实现 Comparable 协议
    static func < (lhs: Icon, rhs: Icon) -> Bool {
        return lhs.createDate < rhs.createDate
    }
    
    let iconId: String
    let svgBase64: String
    let createDate: Date
    
    init(iconId: String, svg: String, createDate: Date) {
        self.iconId = iconId
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: svg, options: .prettyPrinted)
            self.svgBase64 = jsonData.base64EncodedString(options: .endLineWithLineFeed)
        } catch {
            self.svgBase64 = ""
        }
        self.createDate = createDate
    }
    
    init(iconId: String, svgData: Data, createDate: Date) {
        self.iconId = iconId
        self.svgBase64 = svgData.base64EncodedString(options: .endLineWithLineFeed)
        self.createDate = createDate
    }
    
    init(url: URL) {
        self.iconId = url.lastPathComponent
        self.svgBase64 = readFileContent(url: url).base64EncodedString(options: .endLineWithLineFeed)
        do {
            self.createDate = try url.resourceValues(forKeys: [.creationDateKey]).creationDate!
        } catch {
            self.createDate = Date()
        }
    }
    
}
