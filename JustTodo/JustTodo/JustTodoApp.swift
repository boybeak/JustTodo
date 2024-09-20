//
//  JustTodoApp.swift
//  JustTodo
//
//  Created by Beak on 2024/5/24.
//

import SwiftUI
import NoLaunchWin

@main
struct JustTodoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NoLaunchWinView()
        }
    }
}
