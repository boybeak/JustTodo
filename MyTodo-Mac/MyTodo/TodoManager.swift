//
//  TodoManager.swift
//  MyTodo
//
//  Created by Beak on 2024/5/12.
//

import AppKit

class TodoManager {
    // 创建一个静态常量实例，用于保存单例对象
    static let shared = TodoManager()
    
    let groupDataSource: GroupDataSource = GroupDataSource()
    
    let todoDataSource: TableDataSource = TableDataSource()
    
    private let onGroupChanged:((Group) -> Void) = { group in
    }
        
    // 防止通过其他方式创建该类的实例
    private init() {
        groupDataSource.registerGroupChangedCallback(callback: onGroupChanged)
    }
    
    func newGroup(title: String) {
        let group = TodoDB.shared.groupTable.newGroup(title: title)
        if (group == nil) {
            return
        }
        groupDataSource.checkGroup(group: group!)
    }
    
    func newTodo(text: String) {
        
    }
    
}

class TableDataSource: NSObject, NSTableViewDataSource {
    
    var data: [String] = []
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[row]
    }
    
    func add(text: String) {
        data.append(text)
    }
}

class TableDelegate: NSObject, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30 // Set height of each row
    }
    
    // You can implement more delegate methods as needed
}

class GroupDataSource: NSObject, NSTableViewDataSource {
    
    private(set) var data: [Group]
    
    private(set) var current: Group!
    
    private var groupChangedCallbacks: [(Group) -> Void] = []
    
    override init() {
        data = TodoDB.shared.groupTable.queryGroups()
    }
    
    func refresh() {
        data = TodoDB.shared.groupTable.queryGroups()
    }
    
    func checkGroup(group: Group) {
        self.current = group
        refresh()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[row]
    }
    
    func registerGroupChangedCallback(callback: @escaping (Group) -> Void) {
        groupChangedCallbacks.append(callback)
    }
    
    func unregisterGroupChangedCallback(callback: @escaping (Group) -> Void) {
        if let index = groupChangedCallbacks.firstIndex(where: { $0 as AnyObject === callback as AnyObject }) {
            groupChangedCallbacks.remove(at: index)
        }
    }
    
    func notifyGroupChanged(_ group: Group) {
        let callbacks = groupChangedCallbacks
        for callback in callbacks {
            callback(group)
        }
    }
}

class GroupDelegate: NSObject, NSTableViewDelegate {
    
    private var selecteIndex = 0
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        // 这里返回每个行的高度，可以是固定值也可以根据内容动态计算
        return 40 // 这里返回一个固定高度，你可以根据需要进行调整
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        // 执行你的操作
        print("Row \(row) was selected")
        
        selecteIndex = row
        tableView.reloadData()
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let dataSource = tableView.dataSource as! GroupDataSource
        let item = dataSource.tableView(tableView, objectValueFor: nil, row: row) as! Group
        
        // 创建自定义的 NSView 或 NSCell 来显示每一行的内容
        let cellIdentifier = "column"
        var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? GroupView
        if cellView == nil {
            cellView = GroupView()
            cellView?.identifier = NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)
        }
        
        NSLog("tableView row cellView.width=\(String(describing: cellView?.frame.width)) tableView.width=\(tableView.frame.width)")
        
        cellView?.wantsLayer = true
        if (selecteIndex == row) {
            cellView?.layer?.backgroundColor = NSColor.lightGray.cgColor
        } else {
            cellView?.layer?.backgroundColor = NSColor.clear.cgColor
        }
        
        
//        cellView?.textField.stringValue = item.title!
        
        return cellView
    }
}
