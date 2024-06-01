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
    case getBuildInIcons = "getBuildInIcons"
    case getCustomIcons = "getCustomIcons"
    case removeCustomIcon = "removeCustomIcon"
    case openIconsWindow = "openIconsWindow"
}

let consoleLog: (String, (WKWebView, Any) -> Void) = ("consoleLog", { webView, msg in
    let params = msg as! [Any]
    let log = params.map {
        String(describing: $0)
    }.joined(separator: "")
    NSLog("js:\(log)")
})

let getGroups: (String, (WKWebView, Any) -> Void) = ("getGroups", { webView, msg in
    let eventId = msg as! String
    let groups = TodoDB.shared.groupTable.queryGroups()
    
    do {
        let json = try jsonEncoder.encode(groups)
        let jsonStr = String(data: json, encoding: .utf8)!
        webView.jsHandleResult(eventId: eventId, result: jsonStr)
    } catch {
        
    }
})

let newGroup: (String, (WKWebView, Any) -> Void) = ("newGroup", { webView, msg in
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
})

let deleteGroup: (String, (WKWebView, Any) -> Void) = ("deleteGroup", { webView, msg in
    let groupId = msg as! String
    TodoDB.shared.groupTable.deleteGroup(id: groupId)
})

let getTodoItems: (String, (WKWebView, Any) -> Void) = ("getTodoItems", { webView, msg in
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
})

let newTodoItem: (String, (WKWebView, Any) -> Void) = ("newTodoItem", { webView, msg in
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
})

let checkTodoItem: (String, (WKWebView, Any) -> Void) = ("checkTodoItem", { webView, msg in
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
})

let deleteTodoItem: (String, (WKWebView, Any) -> Void) = ("deleteTodoItem", { webView, msg in
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
})

let getBuildInIcons: (String, (WKWebView, Any) -> Void) = ("getBuildInIcons", { webView, msg in
    let eventId = msg as! String
    IconManager.shared.getBuildInIcons { icons in
        do {
            let jsonData = try jsonEncoder.encode(icons)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView.jsHandleResult(eventId: eventId, result: jsonString)
            }
        } catch {}
    }
})

let getCustomIcons: (String, (WKWebView, Any) -> Void) = ("getCustomIcons", { webView, msg in
    let eventId = msg as! String
    IconManager.shared.getCustomIcons { icons in
        do {
            let jsonData = try jsonEncoder.encode(icons)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                webView.jsHandleResult(eventId: eventId, result: jsonString)
            }
        } catch {}
    }
})

let removeCustomIcon: (String, (WKWebView, Any) -> Void) = ("removeCustomIcon", { webView, msg in
    let iconId = msg as! String
    IconManager.shared.deleteIcon(iconId: iconId)
})

let openIconsWindow: (String, (WKWebView, Any) -> Void) = ("openIconsWindow", { webView, msg in
    IconManager.shared.openIconsWindow()
})

let openIconsChooser: (String, (WKWebView, Any) -> Void) = ("openIconsChooser", { webView, msg in
    IconManager.shared.openSvgChooser()
})

let jsonEncoder = JSONEncoder()
let indexJsHandlers: [String: (WKWebView, Any) -> Void] = mapOf(
    consoleLog, 
    getGroups, newGroup, deleteGroup,
    getTodoItems, newTodoItem, checkTodoItem, deleteTodoItem,
    getBuildInIcons, getCustomIcons, removeCustomIcon, openIconsWindow
)
let iconsJsHandlers:  [String: (WKWebView, Any) -> Void] = mapOf(
    consoleLog, getCustomIcons, removeCustomIcon, openIconsChooser
)
