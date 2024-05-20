//
//  main.swift
//  JustTodo
//
//  Created by Beak on 2024/5/20.
//

import Cocoa

class JustTodoApplication: NSApplication {}

let app = JustTodoApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.run()
