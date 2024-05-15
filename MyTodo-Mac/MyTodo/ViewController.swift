//
//  ViewController.swift
//  MyTodo
//
//  Created by Beak on 2024/5/11.
//

import Cocoa

class ViewController: NSViewController, NSTextViewDelegate {
    
    private static let EDITOR_HEIGHT = CGFloat(32)
    private static let SEPARATOR_COLOR = NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    
    private var groupList: NSScrollView!
    private var groupTable: NSTableView!
    
    private let navigatorDelegate = GroupDelegate()
    
    private let tableDelegate = TableDelegate()
    
    private var contentTable: NSTableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = NSStackView()
        container.orientation = .horizontal
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let noteContainer = NSStackView()
        noteContainer.orientation = .vertical
        noteContainer.translatesAutoresizingMaskIntoConstraints = false

        let groupContainer = makeNavigator()
        
        container.addArrangedSubview(groupContainer)
        
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
            groupContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            groupContainer.topAnchor.constraint(equalTo: container.topAnchor),
            groupContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            groupContainer.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        NSLayoutConstraint.activate([
            separator1.leadingAnchor.constraint(equalTo: groupContainer.trailingAnchor),
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
    
    private func makeNavigator()-> NSView {
        
        let scrollView = NSScrollView()
        scrollView.verticalScroller = nil
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = NSEdgeInsetsZero
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let table = NSTableView()
        table.headerView = nil
        table.selectionHighlightStyle = .none
        table.focusRingType = .none
        table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = TodoManager.shared.groupDataSource
        table.delegate = navigatorDelegate
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        column.title = "Items"
        column.resizingMask = .autoresizingMask
        table.addTableColumn(column)
        
        
        scrollView.documentView = table
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        table.reloadData()
        
        groupTable = table
        groupList = scrollView
        
        let groupAddBtn = NSButton()
        groupAddBtn.image = NSImage(systemSymbolName: "plus.app", accessibilityDescription: nil)
        groupAddBtn.imagePosition = .imageOnly
        groupAddBtn.action = #selector(addGroup)
        
        let groupContainer = NSStackView()
        groupContainer.orientation = .vertical
        
        groupContainer.addArrangedSubview(groupAddBtn)
        groupContainer.addArrangedSubview(groupList)
        
        NSLayoutConstraint.activate([
            groupAddBtn.topAnchor.constraint(equalTo: groupContainer.topAnchor),
            groupAddBtn.trailingAnchor.constraint(equalTo: groupContainer.trailingAnchor),
            groupAddBtn.widthAnchor.constraint(equalToConstant: 40),
            groupAddBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            groupList.topAnchor.constraint(equalTo: groupAddBtn.bottomAnchor),
            groupList.bottomAnchor.constraint(equalTo: groupContainer.bottomAnchor),
            groupList.leadingAnchor.constraint(equalTo: groupContainer.leadingAnchor),
            groupList.trailingAnchor.constraint(equalTo: groupContainer.trailingAnchor)
        ])
        
        return groupContainer
    }
    
    private func makeList()-> NSView {
        let scrollView = NSScrollView()
        
        contentTable = NSTableView()
        contentTable?.headerView = nil
        contentTable?.selectionHighlightStyle = .none
        contentTable?.focusRingType = .none
        contentTable?.dataSource = TodoManager.shared.todoDataSource
        contentTable?.delegate = tableDelegate
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column"))
        column.title = "Items"
        contentTable?.addTableColumn(column)
        
        scrollView.documentView = contentTable
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        contentTable?.reloadData()
        
        return scrollView
    }
    
    private func makeEditor()-> NSView {
        let editor = NSStackView()
        editor.spacing = 0
        editor.orientation = .horizontal
        
        let input = NSTextView()
        input.textContainerInset = NSSize(width: 8, height: 9)
        input.font = NSFont.systemFont(ofSize: 14)
        input.delegate = self
        
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
    
    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(insertNewline(_:)) {
            let data = textView.string
            if (data.isEmpty) {
                return true
            }
            TodoManager.shared.todoDataSource.add(text: data)
            contentTable?.reloadData()
            textView.string = ""
            // Enter key pressed
            NSLog("textView")
            return true // Indicating that the event has been handled
        }
        return false // Event not handled, letting the system handle it
    }
    
    @objc func addGroup() {
        
        TodoManager.shared.newGroup(title: "XYZw")

        groupTable.reloadData()
        NSLog("addGroup count=\(TodoDB.shared.groupTable.count())")
    }
    
}

