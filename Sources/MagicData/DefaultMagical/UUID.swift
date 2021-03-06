//
//  UUID.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension UUID: Magical, MagicalPrimaryValue, MagicStringConvert {
    public static func create(_ value: String?, magic: MagicData) async throws -> UUID? {
        if let value = value {
            return UUID(uuidString: value)
        } else {
            return nil
        }
    }

    public static var deafultPrimaryValue: UUID {
        UUID()
    }

    static public var type: MagicalType = .string

    public func convert(magic: MagicData) async throws -> String {
        return self.uuidString
    }
}
