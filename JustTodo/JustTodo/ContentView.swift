//
//  ContentView.swift
//  JustTodo
//
//  Created by Beak on 2024/5/24.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    var body: some View {
        ZStack {
            if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
                let fileURL = URL(fileURLWithPath: htmlPath)
                WebView(url: fileURL, javascriptHandlers: indexJsHandlers)
            }
        }.frame(width: 320, height: 480)
    }
}

#Preview {
    ContentView()
}
