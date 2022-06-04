//
//  String.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

extension String: Magical, MagicalPrimaryValue, MagicStringConvert {
    public static func create(_ value: String?) -> String? {
        if let value = value {
            return value
        } else {
            return nil
        }
    }

    public static var defualtValue: String {
        ""
    }

    public static var deafultPrimaryValue: String {
        UUID().uuidString
    }
    
    static public var type: MagicalType = .string

    public func convert() -> String {
        return self
    }
}
