//
//  ContentView.swift
//  JustTodo
//
//  Created by Beak on 2024/5/24.
//

import SwiftUI
import WebKit

struct ContentView: View {
    
    private let webViewHolder = WKWebViewHolder()
    @State private var callbackId: UUID? = nil
    
    var body: some View {
        ZStack {
            if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
                let fileURL = URL(fileURLWithPath: htmlPath)
                WebView(url: fileURL, javascriptHandlers: indexJsHandlers, holder: webViewHolder)
            }
        }.onAppear(perform: {
            self.callbackId = IconManager.shared.addCallback(callback: newIconCallback(holder: self.webViewHolder))
        })
        .onDisappear(perform: {
            IconManager.shared.removeCallback(id: callbackId!)
        })
    }
}

#Preview {
    ContentView()
}
