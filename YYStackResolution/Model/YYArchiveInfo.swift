//
//  YYArchiveInfo.swift
//  YYStackResolution
//
//  Created by 王林 on 2021/6/10.
//

import Cocoa

enum YYArchiveFileType: Int {
    case XCARCHIVE = 1
    case SDYM = 2
}

class YYArchiveInfo: NSObject {
    ///  dSYM 路径
    var dSYMFilePath: String?
    /// dSYM 文件名
    var dSYMFileName: String?
    /// archive 文件名
    var archiveFileName: String?
    /// archive 文件路径
    var archiveFilePath: String?
    /// uuids
    var uuidInfos: [YYUUIDInfo]?
    /// 文件类型
    var archiveFileType: YYArchiveFileType?
}
