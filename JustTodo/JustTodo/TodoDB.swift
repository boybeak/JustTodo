//
//  TodoDB.swift
//  JustTodo
//
//  Created by Beak on 2024/5/20.
//

import Foundation
import CoreData
import AppKit

class TodoDB {
    
    static let shared: TodoDB = TodoDB()
    
    // 持久化容器
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "JustTodo")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // 上下文
    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    var groupTable: GroupTable {
        return GroupTable(context: context)
    }
    
    var todoItemTable: TodoItemTable {
        return TodoItemTable(context: context)
    }
    
    private init(){
        
    }
    
}

class GroupTable {
    
    private weak var context: NSManagedObjectContext?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func count()-> Int {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        do {
            return try context?.count(for: fetchRequest) ?? 0
        } catch {
            NSLog("count error")
        }
        return 0
    }
    
    func getGroup(id: String)-> Group? {
        let groupReq = Group.fetchRequest()
        groupReq.predicate = NSPredicate(format: "id == %@", UUID(uuidString: id)! as CVarArg)
        do {
            let groups = try context?.fetch(groupReq)
            if (groups == nil || groups!.isEmpty) {
                return nil
            }
            return groups![0]
        } catch {
            NSLog("getGroup error")
        }
        return nil
    }
    
    func newGroup(title: String)-> Group? {
        if (context == nil) {
            return nil
        }
        
        let group = Group(context: context!)
        
        group.id = UUID()
        group.title = title
        group.create_at = Date()
        group.keep_front = false
        group.icon = ""
        
        context?.insert(group)
        
        commit()
        
        return group
    }
    
    func queryGroups()-> [Group] {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        do {
            let groups = try context?.fetch(fetchRequest)
            return groups ?? []
        } catch {
            NSLog("queryGroups error")
        }
        return []
    }
    
    func deleteGroup(id: String) {
        let featchReq = Group.fetchRequest()
        featchReq.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let items = TodoDB.shared.todoItemTable.getItems(groupId: id)
            for item in items {
                context?.delete(item)
            }
            let fetchResults = try context?.fetch(featchReq) as? [Group]
            let group = fetchResults?[0]
            if (group == nil) {
                return
            }
            context?.delete(group!)
            
            commit()
        } catch {
            NSLog("deleteGroup error")
        }
    }
    
    private func commit() {
        if ((context?.hasChanges) != nil) {
            do {
                try context?.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

class TodoItemTable {
    private weak var context: NSManagedObjectContext?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getItems(groupId: String)-> [Item] {
        let group = TodoDB.shared.groupTable.getGroup(id: groupId)
        if (group == nil) {
            return []
        }
        let fetchReq = Item.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "group_id=%@", group!)
        fetchReq.sortDescriptors = [
            // unfinished first
            NSSortDescriptor(key: "finished", ascending: true),
            // Recent first
            NSSortDescriptor(key: "create_at", ascending: false)
        ]
        do {
            let items = try context?.fetch(fetchReq)
            return items ?? []
        } catch {
            
        }
        return []
    }
    
    func newItem(groupId: String, text: String)-> Item? {
        
        let group = TodoDB.shared.groupTable.getGroup(id: groupId)
        if (group == nil) {
            return nil
        }
        do {
            let item = Item(context: context!)
            item.id = UUID()
            item.create_at = Date()
            item.text = text
            item.finished = false
            item.group_id = group!
            
            try context?.save()
            commit()
            return item
        } catch {
            NSLog("newItem error")
        }
        return nil
    }
    
    func toggleItem(todoId: String, checked: Bool)-> Item? {
        let item = getItem(todoId: todoId)
        if (item == nil) {
            return nil
        }
        
        item?.finished = checked
        commit()
        return item
    }
    
    func deleteItem(todoId: String)-> Item? {
        let item = getItem(todoId: todoId)
        if (item == nil) {
            return nil
        }
        context?.delete(item!)
        commit()
        return item!
    }
    
    func getItem(todoId: String)-> Item? {
        let fetchReq = Item.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "id=%@", UUID(uuidString: todoId)! as CVarArg)
        do {
            let item = try context?.fetch(fetchReq)
            return item?[0]
        } catch {
           return nil
        }
    }
    
    private func commit() {
        if ((context?.hasChanges) != nil) {
            do {
                try context?.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension Group: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(keep_front, forKey: .keep_top)
        try container.encode(create_at, forKey: .create_at)
    }
}

extension Item: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(create_at, forKey: .create_at)
        try container.encode(finished, forKey: .finished)
        try container.encode(group_id?.id, forKey: .group_id)
    }
}

enum CodingKeys: String, CodingKey {
        case id
        case title
        case icon
        case keep_top
        case create_at
        case text
        case finished
        case group_id
    }

