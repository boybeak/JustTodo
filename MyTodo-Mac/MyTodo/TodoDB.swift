//
//  TodoDB.swift
//  MyTodo
//
//  Created by Beak on 2024/5/13.
//

import Foundation
import CoreData
import AppKit

class TodoDB {
    
    static let shared: TodoDB = TodoDB()
    
    // 持久化容器
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyTodo")
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
    
    func newGroup(title: String)-> Group? {
        if (context == nil) {
            return nil
        }
        
        let group = Group(context: context!)
        
        group.id = UUID()
        group.title = title
        group.create_at = Date()
        group.keep_top = false
        group.icon = ""
        
        context?.insert(group)
        
        commit()
        
        return group
    }
    
    func queryGroups()-> [Group] {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        do {
            let groups = try context?.fetch(fetchRequest)
            NSLog("queryGroups count=\(String(describing: groups?.count))")
            return groups ?? []
        } catch {
            NSLog("queryGroups error")
        }
        return []
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
