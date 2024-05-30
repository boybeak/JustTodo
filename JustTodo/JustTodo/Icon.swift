//
//  Icon.swift
//  JustTodo
//
//  Created by Beak on 2024/5/30.
//

import Foundation

class Icon: Codable {
    let iconId: String
    let svgBase64: String
    
    init(iconId: String, svg: String) {
        self.iconId = iconId
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: svg, options: .prettyPrinted)
            self.svgBase64 = jsonData.base64EncodedString(options: .endLineWithLineFeed)
        } catch {
            self.svgBase64 = ""
        }
    }
    
    init(iconId: String, svgData: Data) {
        self.iconId = iconId
        self.svgBase64 = svgData.base64EncodedString(options: .endLineWithLineFeed)
    }
    
}
