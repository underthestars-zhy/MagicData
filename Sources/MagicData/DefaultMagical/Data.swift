//
//  Data.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension Data: Magical, MagicDataConvert {
    public static func create(_ value: Self?, magic: MagicData) async throws -> Self? {
        if let value = value {
            return value
        } else {
            return nil
        }
    }

    static public var type: MagicalType = .data

    public func convert() -> Self {
        return self
    }
}

