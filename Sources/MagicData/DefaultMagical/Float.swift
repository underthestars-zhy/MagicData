//
//  Float.swift
//  
//
//  Created by 朱浩宇 on 2022/6/14.
//

import Foundation

extension Float: Magical, MagicDoubleConvert {
    public static func create(_ value: Double?, magic: MagicData) async throws -> Self? {
        if let value = value {
            return Float(value)
        } else {
            return nil
        }
    }

    static public var type: MagicalType = .double

    public func convert(magic: MagicData) async throws -> Double {
        return Double(self)
    }
}
