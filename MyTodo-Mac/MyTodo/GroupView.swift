//
//  GroupView.swift
//  MyTodo
//
//  Created by Beak on 2024/5/14.
//

import AppKit

class GroupView: NSView {
    
    var stackView: NSStackView!
    var imageView: NSImageView!
    var textField: NSTextField!
    var enterCallback: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.autoresizingMask = [.width, .height]
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Initialize stack view
        stackView = NSStackView(frame: frameRect)
        stackView.autoresizingMask = [.width, .height]
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // Initialize image view
        let image = NSImage(systemSymbolName: "doc.plaintext", accessibilityDescription: nil)
        imageView = NSImageView(image: image!)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        // Initialize text field
        textField = NSTextField(frame: NSRect.zero)
        textField.font = NSFont.systemFont(ofSize: 16)
        textField.focusRingType = .none
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = false
        textField.drawsBackground = false
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
//        textField.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GroupView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        enterCallback?()
    }
}
