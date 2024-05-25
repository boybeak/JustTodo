//
//  AboutController.swift
//  JustTodo
//
//  Created by Beak on 2024/5/22.
//

import WebKit

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    
    static let JS_FUN_CONSOLE_LOG = "consoleLog"
    
    private(set) var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view = webView
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    // WKNavigationDelegate 方法，当 WKWebView 即将加载一个请求时调用
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // 检查请求中的 URL 是否为链接点击
        if navigationAction.navigationType == .linkActivated {
            // 在默认浏览器中打开链接
            if let url = navigationAction.request.url {
                NSWorkspace.shared.open(url)
                // 取消 WKWebView 加载当前请求
                decisionHandler(.cancel)
                return
            }
        }
        // 允许 WKWebView 加载当前请求
        decisionHandler(.allow)
    }
    
    func load(page: String) {
        if let htmlPath = Bundle.main.path(forResource: page, ofType: "html") {
            let fileURL = URL(fileURLWithPath: htmlPath)
            
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            
            let userContentController = webView.configuration.userContentController
            userContentController.removeScriptMessageHandler(forName: WebViewController.JS_FUN_CONSOLE_LOG)
            userContentController.add(self, name: WebViewController.JS_FUN_CONSOLE_LOG)
        }
    }
    
}

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case ViewController.JS_FUN_CONSOLE_LOG:
            let params = message.body as! [Any]
            let log = params.map {
                String(describing: $0)
            }.joined(separator: "")
            NSLog("js:\(log)")
            break
        default:
            break
        }
    }
}

