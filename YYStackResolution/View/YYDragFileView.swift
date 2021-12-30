//
//  YYDragFileView.swift
//  YYStackResolution
//
//  Created by 王林 on 2021/6/10.
//

import Cocoa

protocol YYDragFileViewDelegate {
    func processFiles(_ urls: [URL])
}

class YYDragFileView: NSView {
    
    lazy var placeholderLbl: NSTextField = {
        let tmp = NSTextField(labelWithString: "请拖入dSYM文件至此")
        tmp.alignment = .center
        tmp.lineBreakMode = .byWordWrapping
        return tmp
    }()
    
    var delegate: YYDragFileViewDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
        layer?.backgroundColor = NSColor.lightGray.cgColor
        
        addSubview(placeholderLbl)
        placeholderLbl.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }

    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {

        isReceivingDrag = false
        let pasteBoard = sender.draggingPasteboard
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], urls.count > 0 {
            delegate?.processFiles(urls)
            return true
        }
        return true
    }

}
