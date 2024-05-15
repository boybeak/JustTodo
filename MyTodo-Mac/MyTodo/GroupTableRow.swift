import Cocoa

class GroupTableRow: NSTableRowView {
    let iconImageView: NSImageView
    let titleLabel: NSTextField
    
    override init(frame frameRect: NSRect) {
        // 创建图标视图
        let iconSize = NSSize(width: 20, height: 20)
        iconImageView = NSImageView(frame: NSRect(origin: .zero, size: iconSize))
        iconImageView.imageScaling = .scaleProportionallyUpOrDown
        
        // 创建文本标签
        titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        titleLabel.lineBreakMode = .byTruncatingTail
        
        super.init(frame: frameRect)
        
        // 添加图标和文本标签到视图中
        addSubview(iconImageView)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        
        // 计算图标和文本标签的位置
        let iconSize = iconImageView.frame.size
        let labelSize = titleLabel.intrinsicContentSize
        
        let totalHeight = iconSize.height + labelSize.height
        let yOffset = (bounds.height - totalHeight) / 2.0
        
        iconImageView.frame.origin = NSPoint(x: bounds.midX - iconSize.width / 2.0, y: yOffset)
        
        titleLabel.frame = NSRect(x: bounds.midX - labelSize.width / 2.0, y: yOffset + iconSize.height, width: labelSize.width, height: labelSize.height)
    }
    
    // 设置图标和标题
    func setIcon(_ image: NSImage?) {
        iconImageView.image = image
    }
    
    func setTitle(_ title: String?) {
        titleLabel.stringValue = title ?? ""
    }
}
