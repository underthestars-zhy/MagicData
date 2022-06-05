//
//  Dictionary.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension Dictionary: Magical, MagicDataConvert where Key: Codable, Value: Codable {
    public static func create(_ value: Data?, magic: MagicData) async throws -> Self? {
        if let value = value {
            return try? JSONDecoder().decode(Self.self, from: value)
        } else {
            return nil
        }
    }
    
    public static var type: MagicalType {
        return .data
    }

    public func convert() -> Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}

