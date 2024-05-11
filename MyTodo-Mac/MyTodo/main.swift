//
//  main.swift
//  MyTodo
//
//  Created by Beak on 2024/5/11.
//

import Cocoa

class MyApplication: NSApplication {}

let app = MyApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.run()
