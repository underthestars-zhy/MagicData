//
//  Arrary.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension Array: Magical, MagicDataConvert where Element: Codable {
    public static func create(_ value: Data?, magic: MagicData) async throws -> Self? {
        if let Magic = Element.self as? MagicObject.Type {
            if let value = value {
                let zIndexs = try JSONDecoder().decode([Int].self, from: value)
                print(zIndexs)
                return try await zIndexs.asyncCompactMap { int in
                    try await Magic.create(int, magic: magic) as? Element
                }
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
        if Element.self as? MagicObject.Type != nil {
            let list = try await self.asyncCompactMap { object in
                try await (object as? any MagicObject)?.convert(magic: magic)
            }

            return try JSONEncoder().encode(list)
        } else {
            return try JSONEncoder().encode(self)
        }
    }
}

