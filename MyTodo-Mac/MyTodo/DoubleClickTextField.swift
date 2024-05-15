import Cocoa

class NonEditingTextField: NSTextField {
    
    private var isEditingEnabled = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        // 初始化时默认不可编辑
        self.isEditable = false
        self.isSelectable = false
    }
    
    override func mouseDown(with event: NSEvent) {
        // 鼠标点击时不进入编辑状态
        super.mouseDown(with: event)
        if isEditingEnabled {
            self.window?.makeFirstResponder(self)
        } else {
            self.window?.makeFirstResponder(nil)
        }
    }
    
    override func textShouldBeginEditing(_ textObject: NSText) -> Bool {
        // 禁止在单击时进入编辑状态
        return isEditingEnabled
    }
    
    /// 允许外部手动设置编辑状态
    func setEditingEnabled(_ enabled: Bool) {
        isEditingEnabled = enabled
        self.isEditable = enabled
    }
}


class CustomRowView: NSTableRowView {
    
    var stackView: NSStackView!
    var imageView: NSImageView!
    var textField: NSTextField!
    var enterCallback: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // Initialize stack view
        stackView = NSStackView(frame: frameRect)
        stackView.orientation = .horizontal
        stackView.spacing = 8
        stackView.alignment = .centerY
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.2),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -0.2),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // Initialize image view
        let image = NSImage(systemSymbolName: "doc.plaintext", accessibilityDescription: nil)
        imageView = NSImageView(image: image!)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        // Initialize text field
        textField = NSTextField(frame: NSRect.zero)
        textField.font = NSFont.systemFont(ofSize: 16)
        textField.focusRingType = .none
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.drawsBackground = false
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        NSLog("drawSelection")
        if self.selectionHighlightStyle != .none {
            let selectionRect = bounds.insetBy(dx: 2.5, dy: 2.5)
            NSColor.blue.set()
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 5, yRadius: 5)
            selectionPath.fill()
        }
    }
}

extension CustomRowView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        enterCallback?()
    }
}


class CustomRowView2: NSTableRowView {
    
    let stackView = NSStackView()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        stackView.orientation = .vertical
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        // 添加子视图到 stackView 中
        let label1 = NSTextField(labelWithString: "Label 1")
        let label2 = NSTextField(labelWithString: "Label 2")
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        
        // 设置 stackView 的位置和大小
        let padding: CGFloat = 10
        stackView.frame = NSRect(x: padding, y: padding, width: bounds.width - 2 * padding, height: bounds.height - 2 * padding)
    }
    
    override var isSelected: Bool {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isSelected {
            NSColor.selectedControlColor.setFill()
            dirtyRect.fill()
        } else {
            super.draw(dirtyRect)
        }
    }
}
