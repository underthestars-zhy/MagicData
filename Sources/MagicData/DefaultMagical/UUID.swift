//
//  UUID.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension UUID: Magical, MagicalPrimaryValue, MagicStringConvert {
    public static func create(_ value: String?) -> UUID? {
        if let value = value {
            return UUID(uuidString: value)
        } else {
            return nil
        }
    }

    public static var defualtValue: UUID {
        UUID()
    }

    public static var deafultPrimaryValue: UUID {
        UUID()
    }

    static public var type: MagicalType = .string

    public func convertToString() -> String {
        return self.uuidString
    }
}
