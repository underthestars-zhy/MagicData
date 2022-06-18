//
//  Dictionary.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension Dictionary: Magical, MagicDataConvert where Key: Codable, Value: Codable {
    public static func create(_ value: Data?, magic: MagicData) async throws -> Self? {
        if let Magic = Value.self as? MagicObject.Type {
            if let value = value {
                let decode = try JSONDecoder().decode([Key: Int].self, from: value)
                var res = [Key: Value]()

                for (key, value) in decode {
                    res[key] = try await Magic.create(value, magic: magic) as? Value
                }

                return res
            } else {
                return nil
            }
        } else {
            if let value = value {
                return try JSONDecoder().decode(Self.self, from: value)
            } else {
                return nil
            }
        }
    }
    
    public static var type: MagicalType {
        return .data
    }

    public func convert(magic: MagicData) async throws -> Data {
        if Value.self as? MagicObject.Type != nil {
            var list = [Key: Int]()

            for (key, value) in self {
                list[key] = try await (value as? any MagicObject)?.convert(magic: magic)
            }

            return try JSONEncoder().encode(list)
        } else {
            return try JSONEncoder().encode(self)
        }
    }
}


