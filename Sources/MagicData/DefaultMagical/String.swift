//
//  String.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

extension String: Magical, MagicalPrimaryValue, MagicStringConvert {
    static public var deafult: String {
        UUID().uuidString
    }
    
    static public var type: MagicalType = .string

    public func convertToString() -> String {
        return self
    }
}
