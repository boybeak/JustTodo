//
//  AboutView.swift
//  JustTodo
//
//  Created by Beak on 2024/5/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            if let htmlPath = Bundle.main.path(forResource: "about", ofType: "html") {
                let fileURL = URL(fileURLWithPath: htmlPath)
                WebView(url: fileURL, javascriptHandlers: indexJsHandlers)
            }
        }
    }
}
