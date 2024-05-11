//
//  ViewController.swift
//  MyTodo
//
//  Created by Beak on 2024/5/11.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = NSStackView()
        container.orientation = .vertical
        container.translatesAutoresizingMaskIntoConstraints = false

        let navigator = NSView()
        navigator.wantsLayer = true
        navigator.layer?.backgroundColor = NSColor.blue.cgColor
        
        let content = NSView()
        content.wantsLayer = true
        content.layer?.backgroundColor = NSColor.orange.cgColor
        
        let editor = NSView()
        editor.wantsLayer = true
        editor.layer?.backgroundColor = NSColor.purple.cgColor
        
        container.addArrangedSubview(navigator)
        container.addArrangedSubview(content)
        container.addArrangedSubview(editor)
        
        self.view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            navigator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            navigator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            navigator.topAnchor.constraint(equalTo: container.topAnchor),
            navigator.heightAnchor.constraint(equalToConstant: 40)
        ])
        NSLayoutConstraint.activate([
            editor.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            editor.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            editor.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            editor.heightAnchor.constraint(equalToConstant: 40)
        ])
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            content.topAnchor.constraint(equalTo: navigator.bottomAnchor),
            content.bottomAnchor.constraint(equalTo: editor.topAnchor)
        ])
    }
}

