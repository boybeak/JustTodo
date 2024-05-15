//
//  TestController.swift
//  MyTodo
//
//  Created by Beak on 2024/5/14.
//

import Foundation
import AppKit

class TestController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let groupView = GroupView()
        groupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupView)
        
        groupView.textField.stringValue = "11111"
        
        NSLayoutConstraint.activate([
            groupView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            groupView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            groupView.topAnchor.constraint(equalTo: view.topAnchor),
            groupView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
