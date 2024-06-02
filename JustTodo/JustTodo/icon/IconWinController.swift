//
//  IconWinController.swift
//  JustTodo
//
//  Created by Beak on 2024/5/30.
//

import AppKit
import SwiftUI
import WebKit

class IconWinController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.title = NSLocalizedString("menu_item_about", comment: "About menu item")
        window.center()
        window.level = .modalPanel
        
        let contentView = NSHostingView(rootView: IconReceiverView())
        window.contentView = contentView
        
        self.init(window: window)
    }
}

struct IconReceiverView: View {
    
    private let webViewHolder = WKWebViewHolder()
    @State private var callbackId: UUID? = nil
    
    private var handlers = [String:(WKWebView, Any) -> Void]()
    
    var body: some View {
        
        ZStack {
            
            if let htmlPath = Bundle.main.path(forResource: "icons", ofType: "html") {
                WebView(url: URL(fileURLWithPath: htmlPath), javascriptHandlers: iconsJsHandlers, holder: webViewHolder)
            }
            Rectangle().frame(width: 320, height: 480)
                .opacity(0.0)
                .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
                    var iconsUrls = [URL]()
                    
                    for (index, provider) in providers.enumerated() {
                        provider.loadItem(forTypeIdentifier: "public.file-url") { item, error in
                            if let data = item as? Data, let fileURL = URL(dataRepresentation: data, relativeTo: nil) {
                                if fileURL.pathExtension == "svg" {
                                    iconsUrls.append(fileURL)
                                }
                            }
                            if !iconsUrls.isEmpty && index == providers.count - 1 {
                                IconManager.shared.addIcons(urls: iconsUrls)
                            }
                        }
                    }
                    return true
                }
        }.onAppear(perform: {
            self.callbackId = IconManager.shared.addCallback(callback: newIconCallback(holder: self.webViewHolder))
        })
        .onDisappear(perform: {
            IconManager.shared.removeCallback(id: callbackId!)
        })
    }
    
}
