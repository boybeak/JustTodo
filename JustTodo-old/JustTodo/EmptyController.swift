//
//  EmptyController.swift
//  JustTodo
//
//  Created by Beak on 2024/5/23.
//

import Foundation
import AppKit

class EmptyController: NSViewController {
    
    private var et: NSTextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        et = NSTextView()
        self.view = et!
    }
}
