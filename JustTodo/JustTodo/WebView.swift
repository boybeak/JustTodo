import SwiftUI
import WebKit

// WebViewCoordinator 用于处理 WebView 的代理方法以及与 JavaScript 的交互
class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    var webView: WKWebView?
    var javascriptHandlers = [String: (WKWebView, Any) -> Void]()
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let handler = javascriptHandlers[message.name] {
            handler(webView!, message.body)
        }
    }
}

// SwiftUIWebView 是一个 SwiftUI 视图，用于显示 WebView 并进行交互
struct WebView: NSViewRepresentable {
    let webView: WKWebView
    let url: URL
    let javascriptHandlers: [String: (WKWebView, Any) -> Void]

    init(url: URL, javascriptHandlers: [String: (WKWebView, Any) -> Void]) {
        self.url = url
        self.javascriptHandlers = javascriptHandlers
        self.webView = WKWebView()
    }

    func makeNSView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator

        for (handlerName, _) in javascriptHandlers {
            webView.configuration.userContentController.add(context.coordinator, name: handlerName)
        }
        
        let webPreferences = webView.configuration.defaultWebpagePreferences
        webPreferences!.allowsContentJavaScript = true

        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(URLRequest(url: url))
        context.coordinator.webView = nsView
        context.coordinator.javascriptHandlers = javascriptHandlers
    }

    func makeCoordinator() -> WebViewCoordinator {
        return WebViewCoordinator()
    }
}
