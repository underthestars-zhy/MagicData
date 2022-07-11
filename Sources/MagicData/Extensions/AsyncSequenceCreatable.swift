//
//  AsyncSequenceCreatable.swift
//  
//
//  Created by 朱浩宇 on 2022/7/10.
//

import Foundation

public protocol AsyncSequenceCreatable {
    static func create(_ host: Any) throws -> [(Codable?, Int)]
    static func createObject<Object: MagicObject & MagicDataConvert>(_ value: Int, magic: MagicData, object: Object.Type) async throws -> Object?
    static func getObject() -> MagicObject.Type
}

extension AsyncSequenceCreatable {
    public static func createObject<Object>(_ value: Int, magic: MagicData, object: Object.Type) async throws -> Object? where Object : MagicObject {
        try await Object.create(value, magic: magic)
    }
}

extension Array: AsyncSequenceCreatable where Element: MagicObject {
    public static func getObject() -> MagicObject.Type {
        return Element.self
    }

    public static func create(_ host: Any) throws -> [(Codable?, Int)] {
        if let data = host as? Data {
            return try JSONDecoder().decode([Int].self, from: data).map { i in
                (nil, i)
            }
        } else {
            throw MagicError.missValue
        }
    }
}

extension Dictionary: AsyncSequenceCreatable where Value: MagicObject, Key: Codable {
    public static func getObject() -> MagicObject.Type {
        return Value.self
    }

    public static func create(_ host: Any) throws -> [(Codable?, Int)] {
        if let data = host as? Data {
            return try JSONDecoder().decode([Key: Int].self, from: data).map { i in
                (i.key, i.value)
            }
        } else {
            throw MagicError.missValue
        }
    }
}

extension MagicalSet: AsyncSequenceCreatable {
    public static func getObject() -> MagicObject.Type {
        return Element.self
    }

    public static func create(_ host: Any) throws -> [(Codable?, Int)] {
        if let data = host as? Data {
            return try JSONDecoder().decode([Int].self, from: data).map { i in
                (nil, i)
            }
        } else {
            throw MagicError.missValue
        }
    }
}
