//
//  JsHandlers.swift
//  JustTodo
//
//  Created by Beak on 2024/5/25.
//

import Foundation
import WebKit

enum JsFunction: String {
    case consoleLog = "consoleLog"
    case getGroups = "getGroups"
    case newGroup = "newGroup"
    case deleteGroup = "deleteGroup"
    case getTodoItems = "getTodoItems"
    case newTodoItem = "newTodoItem"
    case checkTodoItem = "checkTodoItem"
    case deleteTodoItem = "deleteTodoItem"
    case copyText = "copyText"
    case readClipboard = "readClipboard"
    case getIcons = "getIcons"
    case getBuildInIcons = "getBuildInIcons"
    case getCustomIcons = "getCustomIcons"
    case addCustomIcons = "addCustomIcons"
}

extension WKWebView {
    func jsHandleResult(eventId: String, result: String) {
        evaluateJavaScript("bridge.handleResult('\(eventId)', '\(result)')") { (result, error) in
            if let error = error {
                NSLog("Error evaluating JavaScript: \(error)")
            }
        }
    }
}
let jsonEncoder = JSONEncoder()
let indexJsHandlers: [String: (WKWebView, Any) -> Void] = [
    JsFunction.consoleLog.rawValue : { webView, msg in
        let params = msg as! [Any]
        let log = params.map {
            String(describing: $0)
        }.joined(separator: "")
        NSLog("js:\(log)")
    },
    JsFunction.getGroups.rawValue : { webView, msg in
        let eventId = msg as! String
        let groups = TodoDB.shared.groupTable.queryGroups()
        
        do {
            let json = try jsonEncoder.encode(groups)
            let jsonStr = String(data: json, encoding: .utf8)!
            webView.jsHandleResult(eventId: eventId, result: jsonStr)
        } catch {
            
        }
    },
    JsFunction.newGroup.rawValue : { webView, msg in
        let params = msg as! [String]
        let eventId = params[0]
        let title = params[1]
        let icon = params[2]
        
        let group = TodoDB.shared.groupTable.newGroup(title: title, icon: icon)
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
    },
    JsFunction.deleteGroup.rawValue : { webView, msg in
        let groupId = msg as! String
        TodoDB.shared.groupTable.deleteGroup(id: groupId)
    },
    JsFunction.getTodoItems.rawValue : { webView, msg in
        let params = msg as! [String]
        let eventId = params[0]
        let groupId = params[1]
        let items = TodoDB.shared.todoItemTable.getItems(groupId: groupId)
        let result: String
        do {
            let json = try jsonEncoder.encode(items)
            result = String(data: json, encoding: .utf8)!
        } catch {
            result = ""
        }
        webView.jsHandleResult(eventId: eventId, result: result)
    },
    JsFunction.newTodoItem.rawValue : { webView, msg in
        let params = msg as! [String]
        let eventId = params[0]
        let groupId = params[1]
        let text = params[2]
        let newItem = TodoDB.shared.todoItemTable.newItem(groupId: groupId, text: text)
        let result: String
        if newItem == nil {
            result = ""
        } else {
            do {
                let json = try jsonEncoder.encode(newItem!)
                result = String(data: json, encoding: .utf8)!
            } catch {
                result = ""
            }
        }
        webView.jsHandleResult(eventId: eventId, result: result)
    },
    JsFunction.checkTodoItem.rawValue : { webView, msg in
        let params = msg as! [Any]
        let eventId = params[0] as! String
        let todoId = params[1] as! String
        let checked = params[2] as! Int
        
        let item = TodoDB.shared.todoItemTable.toggleItem(todoId: todoId, checked: checked == 1)
        
        let result: String
        if item == nil {
            result = ""
        } else {
            do {
                let json = try jsonEncoder.encode(item!)
                result = String(data: json, encoding: .utf8)!
            } catch {
                result = ""
            }
        }
        webView.jsHandleResult(eventId: eventId, result: result)
    },
    JsFunction.deleteTodoItem.rawValue : { webView, msg in
        let params = msg as! [String]
        let eventId = params[0]
        let todoId = params[1]
        
        let item = TodoDB.shared.todoItemTable.deleteItem(todoId: todoId)
        
        let result: String
        if item == nil {
            result = ""
        } else {
            do {
                let json = try jsonEncoder.encode(item!)
                result = String(data: json, encoding: .utf8)!
            } catch {
                result = ""
            }
        }
        webView.jsHandleResult(eventId: eventId, result: result)
    },
    JsFunction.getIcons.rawValue: { webView, msg in
        let eventId = msg as! String
        
        IconManager.shared.getIcons { icons in
            NSLog("getIcons=\(icons!)")
            DispatchQueue.main.async {
                NSLog("aaaaa icons.size=\(String(describing: icons?.count))")
                do {
                    let json = try jsonEncoder.encode(icons!)
                    let result = String(data: json, encoding: .utf8)!
                    webView.jsHandleResult(eventId: eventId, result: result)
                } catch {
                    
                }
            }
        }
    },
    JsFunction.getBuildInIcons.rawValue: { webView, msg in
        let eventId = msg as! String
        IconManager.shared.getBuildInIcons { icons in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: icons, options: .prettyPrinted)
                let base64 = jsonData.base64EncodedString(options: .endLineWithLineFeed)
                webView.jsHandleResult(eventId: eventId, result: base64)
            } catch {
                
            }
        }
    },
    JsFunction.getCustomIcons.rawValue: { webView, msg in
        let eventId = msg as! String
        IconManager.shared.getCustomIcons { icons in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: icons, options: .prettyPrinted)
                let base64 = jsonData.base64EncodedString(options: .endLineWithLineFeed)
                webView.jsHandleResult(eventId: eventId, result: base64)
            } catch {
                
            }
        }
    },
    JsFunction.addCustomIcons.rawValue: { webView, msg in
        let eventId = msg as! String
        IconManager.shared.chooseIcon { icons in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: icons, options: .prettyPrinted)
                let base64 = jsonData.base64EncodedString(options: .endLineWithLineFeed)
                webView.jsHandleResult(eventId: eventId, result: base64)
            } catch {
                
            }
        }
    }
]
