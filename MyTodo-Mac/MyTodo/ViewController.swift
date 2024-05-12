//
//  ViewController.swift
//  MyTodo
//
//  Created by Beak on 2024/5/11.
//

import Cocoa

class ViewController: NSViewController {
    
    private static let EDITOR_HEIGHT = CGFloat(32)
    private static let SEPARATOR_COLOR = NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    
    private var navigator: NSScrollView!
    
    private let navigatorDataSource = NavigatorDataSource()
    private let navigatorDelegate = NavigatorDelegate()
    
    private let tableDataSource = TableDataSource()
    private let tableDelegate = TableDelegate()
    
    private var selectedButton: NSButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = NSStackView()
        container.orientation = .horizontal
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let noteContainer = NSStackView()
        noteContainer.orientation = .vertical
        noteContainer.translatesAutoresizingMaskIntoConstraints = false

        navigator = makeNavigator()
        navigator.wantsLayer = true
        navigator.layer?.backgroundColor = NSColor.blue.cgColor
        
        container.addArrangedSubview(navigator)
        
        let separator1 = NSView()
        separator1.wantsLayer = true
        separator1.layer?.backgroundColor = ViewController.SEPARATOR_COLOR.cgColor
        
        container.addArrangedSubview(separator1)
        container.addArrangedSubview(noteContainer)
        
        let content = makeList()
        content.wantsLayer = true
        content.layer?.backgroundColor = NSColor.orange.cgColor
        
        let separator2 = NSView()
        separator2.wantsLayer = true
        separator2.layer?.backgroundColor = ViewController.SEPARATOR_COLOR.cgColor
        
        let editor = makeEditor()
        
        noteContainer.addArrangedSubview(content)
        noteContainer.addArrangedSubview(separator2)
        noteContainer.addArrangedSubview(editor)
        
        self.view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            navigator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            navigator.topAnchor.constraint(equalTo: container.topAnchor),
            navigator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            navigator.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        NSLayoutConstraint.activate([
            separator1.leadingAnchor.constraint(equalTo: navigator.trailingAnchor),
            separator1.topAnchor.constraint(equalTo: container.topAnchor),
            separator1.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator1.widthAnchor.constraint(equalToConstant: 0.5)
        ])
        
        NSLayoutConstraint.activate([
            noteContainer.leadingAnchor.constraint(equalTo: separator1.trailingAnchor),
            noteContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            noteContainer.topAnchor.constraint(equalTo: container.topAnchor),
            noteContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            editor.leadingAnchor.constraint(equalTo: noteContainer.leadingAnchor),
            editor.trailingAnchor.constraint(equalTo: noteContainer.trailingAnchor),
            editor.bottomAnchor.constraint(equalTo: noteContainer.bottomAnchor),
            editor.heightAnchor.constraint(equalToConstant: ViewController.EDITOR_HEIGHT)
        ])
        NSLayoutConstraint.activate([
            separator2.leadingAnchor.constraint(equalTo: noteContainer.leadingAnchor),
            separator2.trailingAnchor.constraint(equalTo: noteContainer.trailingAnchor),
            separator2.bottomAnchor.constraint(equalTo: editor.topAnchor),
            separator2.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: noteContainer.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: noteContainer.trailingAnchor),
            content.topAnchor.constraint(equalTo: noteContainer.topAnchor),
            content.bottomAnchor.constraint(equalTo: separator2.topAnchor)
        ])
    }
    
    private func makeNavigator()-> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.verticalScroller = nil
        
        let table = NSTableView()
        table.headerView = nil
        table.dataSource = navigatorDataSource
        table.delegate = navigatorDelegate
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        column.title = "Items"
        table.addTableColumn(column)
        
        scrollView.documentView = table
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        table.reloadData()
        
        return scrollView
    }
    
    private func makeList()-> NSView {
        let scrollView = NSScrollView()
        
        let table = NSTableView()
        table.headerView = nil
        table.dataSource = tableDataSource
        table.delegate = tableDelegate
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        column.title = "Items"
        table.addTableColumn(column)
        
        scrollView.documentView = table
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        table.reloadData()
        
        return scrollView
    }
    
    private func makeEditor()-> NSView {
        let editor = NSStackView()
        editor.spacing = 0
        editor.orientation = .horizontal
        
        let input = NSTextView()
        input.textContainerInset = NSSize(width: 8, height: 9)
        input.font = NSFont.systemFont(ofSize: 14)
        
        let actionImage = NSImage(systemSymbolName: "paperplane.fill", accessibilityDescription: nil)
        let action = NSImageView(image: actionImage!)
        actionImage?.size = NSSize(width: ViewController.EDITOR_HEIGHT, height: ViewController.EDITOR_HEIGHT)
        
        editor.addArrangedSubview(input)
        editor.addArrangedSubview(action)
        
        NSLayoutConstraint.activate([
            input.topAnchor.constraint(equalTo: editor.topAnchor),
            input.bottomAnchor.constraint(equalTo: editor.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            action.topAnchor.constraint(equalTo: editor.topAnchor),
            action.bottomAnchor.constraint(equalTo: editor.bottomAnchor),
            action.widthAnchor.constraint(equalToConstant: ViewController.EDITOR_HEIGHT),
            action.heightAnchor.constraint(equalToConstant: ViewController.EDITOR_HEIGHT)
        ])
        
        return editor
    }
    
}

