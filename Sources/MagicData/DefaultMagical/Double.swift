//
//  Double.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension Double: Magical, MagicDoubleConvert {
    public static func create(_ value: Self?) -> Self? {
        if let value = value {
            return value
        } else {
            return nil
        }
    }

    public static var defualtValue: Self {
        0
    }
    
    static public var type: MagicalType = .double

    public func convert() -> Self {
        return self
    }
}
