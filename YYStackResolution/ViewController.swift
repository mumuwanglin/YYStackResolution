//
//  ViewController.swift
//  YYStackResolution
//
//  Created by 王林 on 2021/6/10.
//

import Cocoa
import SnapKit

class ViewController: NSViewController {
    
    @IBOutlet weak var dragFileView: YYDragFileView!
    @IBOutlet var crashStackTF: NSTextView!
    @IBOutlet var resultTF: NSTextView!
    
    var crashStackDict: Array<YYCrashStack> = []
    var uuidInfo: YYUUIDInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dragFileView.delegate = self
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func analyseCrashStack(stringValue: String) {
        // 移除所有的 Dict
        crashStackDict.removeAll()
        resultTF.string = ""
        
        var stackString = stringValue
        stackString = stackString.replacingOccurrences(of: "[", with: "")
        stackString = stackString.replacingOccurrences(of: "]", with: "")
        stackString = stackString.replacingOccurrences(of: "\n", with: "")
        stackString = stackString.replacingOccurrences(of: "\n", with: "")
        for tmp in stackString.split(separator: ",") {
            let tt = tmp.split(separator: " ")
            let idx = String(tt[0]).replacingOccurrences(of: "\"", with: "")
            let module = String(tt[1])
            let errorAddress = String(tt[2])
            let uuid = String(tt[3])
            let slideAddress = String(tt[5]).replacingOccurrences(of: "\"", with: "")
            let crashStackModel = YYCrashStack(idx: idx, module: module, errorAddress: errorAddress, uuid: uuid, slideAddress: slideAddress)
            crashStackDict.append(crashStackModel)
        }
    }
    
    @IBAction func analyse(_ sender: Any) {
        // 解析堆栈信息
        analyseCrashStack(stringValue: crashStackTF.string)
        if uuidInfo?.executableFilePath == nil {
            dragFileView.placeholderLbl.stringValue = "请拖入dSYM文件"
            return
        }
        for tempDict in crashStackDict {
            
            let tempErrorInt = Int(tempDict.errorAddress?.hexadecimalToDecimal() ?? "0")!
            let tempSlideInt = Int(tempDict.slideAddress ?? "0")!
            
            let tempAddree = "\(tempErrorInt + tempSlideInt)".decimalToHexadecimal()
            
            let result = run(command: "atos -arch arm64 -o \((uuidInfo?.executableFilePath)!) -l \(tempDict.errorAddress!) \(tempAddree)")
                        
            resultTF.string = resultTF.string.appending("\((tempDict.idx)!) \t \(result)")
        }
    }
    
    
    private func run(command: String) -> String {
        let process = SubProcess(cmd: "/bin/sh", args: ["-c", command])
        process.run()
        
        return process.output
    }
    
    func formatDSYM(_ urls: [URL]) {
        let urlString = (urls.first?.path)!
        let uuidsString = run(command: "dwarfdump --uuid \(urlString)")
        dragFileView.placeholderLbl.stringValue = uuidsString
        let pattern = "(?<=\\()[^}]*(?=\\))"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return
        }
        let match = regex.matches(in: uuidsString, options: .reportCompletion, range: NSRange(location: 0, length: uuidsString.count))
        
        if match.count != 0 {
            for result in match {
                let range = result.range
                let ocString = (uuidsString as NSString)
                let arch = ocString.substring(with: range)
                let uuid = ocString.substring(with: NSRange(location: 6, length: range.location - 6 - 2))
                let executableFilePath = ocString.substring(with: NSRange(location: range.location+range.length+2, length: uuidsString.count - (range.location + range.length + 3)))
                let tempInfo = YYUUIDInfo(arch: arch, uuid: uuid, executableFilePath: executableFilePath)
                uuidInfo = tempInfo
            }
        }
        
    }
}

extension ViewController: YYDragFileViewDelegate {
    func processFiles(_ urls: [URL]) {
        for url in urls {
            if url.pathExtension == "dSYM" {
                self.formatDSYM(urls)
            }
        }
    }
}

