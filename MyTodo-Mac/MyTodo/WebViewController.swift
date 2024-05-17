//
//  WebViewController.swift
//  MyTodo
//
//  Created by Beak on 2024/5/15.
//

import AppKit
import WebKit

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    
    static let JS_FUN_CONSOLE_LOG = "consoleLog"
    static let JS_FUN_GET_GROUP = "getGroups"
    static let JS_FUN_NEW_GROUP = "newGroup"
    static let JS_FUN_DELETE_GROUP = "deleteGroup"
    
    private(set) var webView: WKWebView!
    let jsonEncoder = JSONEncoder()

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
        
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let fileURL = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
            
            
            setupJsFunctions(webView: webView)
        }
    }
    
    // 实现 WKNavigationDelegate 中的方法
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 禁用右键菜单
        webView.evaluateJavaScript("document.body.setAttribute('oncontextmenu', 'event.preventDefault();');", completionHandler: nil)
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
        userContentController.add(self, name: WebViewController.JS_FUN_NEW_GROUP)
        userContentController.add(self, name: WebViewController.JS_FUN_DELETE_GROUP)
    }
    
}

extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case WebViewController.JS_FUN_CONSOLE_LOG:
            let params = message.body as! [Any]
            let log = params.map {
                String(describing: $0)
            }.joined(separator: "")
            NSLog("js:\(log)")
            break
        case WebViewController.JS_FUN_GET_GROUP:
            let eventId = message.body as! String
            let groups = TodoDB.shared.groupTable.queryGroups()
            
            do {
                let json = try jsonEncoder.encode(groups)
                let jsonStr = String(data: json, encoding: .utf8)!
                
                webView.jsHandleResult(eventId: eventId, result: jsonStr)
            } catch {
                
            }
            break
        case WebViewController.JS_FUN_NEW_GROUP:
            let params = message.body as! [String]
            let eventId = params[0]
            let title = params[1]
            
            let group = TodoDB.shared.groupTable.newGroup(title: title)
            do {
                if (group != nil) {
                    let json = try jsonEncoder.encode(group)
                    let jsonStr = String(data: json, encoding: .utf8)!
                    webView.jsHandleResult(eventId: eventId, result: jsonStr)
                } else {
                    webView.jsHandleResult(eventId: eventId, result: "")
                }
            } catch {
                
            }
            break
        case WebViewController.JS_FUN_DELETE_GROUP:
            let groupId = message.body as! String
            TodoDB.shared.groupTable.deleteGroup(id: groupId)
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
