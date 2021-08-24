//
//  YYStringExt.swift
//  YYStackResolution
//
//  Created by 王林 on 2021/6/10.
//

import Foundation

extension String {
    
    // MARK: 3.3、字符串转 Int
    /// 字符串转 Int
    /// - Returns: Int
    func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    
    /// 十六进制  转 十进制
    /// - Returns: 十进制
    func hexadecimalToDecimal() -> String {
        let str = self.uppercased().replacingOccurrences(of: "0X", with: "")
        var sum = 0
        for i in str.utf8 {
            // 0-9 从48开始
            sum = sum * 16 + Int(i) - 48
            // A-Z 从65开始，但有初始值10，所以应该是减去55
            if i >= 65 {
                sum -= 7
            }
        }
        return "\(sum)"
    }
    
    
    /// 十进制转 十六进制
    /// - Returns: 十六进制
    func decimalToHexadecimal() -> String {
        return String(Int(self)!, radix: 16)
    }
}
