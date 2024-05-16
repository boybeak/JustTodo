//
//  WebViewController.swift
//  MyTodo
//
//  Created by Beak on 2024/5/15.
//

import AppKit
import WebKit

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    
    static let JS_FUN_GET_GROUP = "getGroups"
    static let JS_FUN_CONSOLE_LOG = "consoleLog"
    
    private(set) var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        webView.navigationDelegate = self
        
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let fileURL = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            
            
            setupJsFunctions(webView: webView)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog("js-error: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog("js-error: \(error.localizedDescription)")
    }
    
    private func setupJsFunctions(webView: WKWebView) {
        let userContentController = webView.configuration.userContentController
        userContentController.add(self, name: WebViewController.JS_FUN_CONSOLE_LOG)
        
        userContentController.add(self, name: WebViewController.JS_FUN_GET_GROUP)
    }
    
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case WebViewController.JS_FUN_GET_GROUP:
            let eventId = message.body as! String
            let groups = TodoDB.shared.groupTable.queryGroups()
            
            let jsonEncoder = JSONEncoder()
            do {
                let json = try jsonEncoder.encode(groups)
                let jsonStr = String(data: json, encoding: .utf8)!
                
                webView.jsHandleResult(eventId: eventId, result: jsonStr)
            } catch {
                
            }
            break
        case WebViewController.JS_FUN_CONSOLE_LOG:
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

extension WKWebView {
    func jsHandleResult(eventId: String, result: String) {
        evaluateJavaScript("handleResult('\(eventId)', '\(result)')") { (result, error) in
            if let error = error {
                NSLog("Error evaluating JavaScript: \(error.localizedDescription)")
            }
        }
    }
}
