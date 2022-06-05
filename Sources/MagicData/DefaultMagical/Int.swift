//
//  Int.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension Int: Magical, MagicalPrimaryValue, MagicIntConvert {
    public static func create(_ value: Int?, magic: MagicData) async throws -> Int? {
        if let value = value {
            return value
        } else {
            return nil
        }
    }

    public static var deafultPrimaryValue: Int {
        0
    }

    static public var type: MagicalType = .int

    public func convert() -> Int {
        return self
    }
}
