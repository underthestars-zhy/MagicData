//
//  URL.swift
//  
//
//  Created by 朱浩宇 on 2022/7/25.
//

import Foundation

extension URL: Magical, MagicStringConvert {
    public static func create(_ value: String?, magic: MagicData) async throws -> Self? {
        if let value = value {
            return URL(string: value)
        } else {
            return nil
        }
    }

    static public var type: MagicalType = .string

    public func convert(magic: MagicData) async throws -> String {
        return self.absoluteString
    }
}
