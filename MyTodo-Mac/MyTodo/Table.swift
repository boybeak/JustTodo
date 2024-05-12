//
//  Table.swift
//  MyTodo
//
//  Created by Beak on 2024/5/12.
//

import AppKit

class TableDataSource: NSObject, NSTableViewDataSource {
    
    var data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8", "Item 9", "Item 10", "Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8", "Item 9", "Item 10"]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data[row]
    }
}

class TableDelegate: NSObject, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30 // Set height of each row
    }
    
    // You can implement more delegate methods as needed
}
