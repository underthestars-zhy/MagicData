//
//  Set.swift
//  
//
//  Created by 朱浩宇 on 2022/6/7.
//

import Foundation

extension Set: Magical, MagicDataConvert where Element: Codable {
    public static func create(_ value: Data?, magic: MagicData) async throws -> Self? {
        if let value {
            return try? JSONDecoder().decode(Self.self, from: value)
        } else {
            return nil
        }
    }

    public static var type: MagicalType {
        return .data
    }

    public func convert(magic: MagicData) async throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
