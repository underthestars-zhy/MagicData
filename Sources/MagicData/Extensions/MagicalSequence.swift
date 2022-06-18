//
//  MagicalSequence.swift
//  
//
//  Created by 朱浩宇 on 2022/6/14.
//

import Foundation

protocol MagicalSequence {
    static func allID(_ data: Data) throws -> [Int]
}

extension MagicalSet: MagicalSequence {
    static func allID(_ data: Data) throws -> [Int] {
        try JSONDecoder().decode([Int].self, from: data)
    }
}
extension Array: MagicalSequence where Element: MagicObject {
    static func allID(_ data: Data) throws -> [Int] {
        try JSONDecoder().decode([Int].self, from: data)
    }
}
extension AsyncMagical: MagicalSequence where Element: MagicalSequence {
    static func allID(_ data: Data) throws -> [Int] {
        if let Dict = Element.self as? ObjectDictionary.Type {
            return try Dict.getAllID(data)
        } else {
            return try JSONDecoder().decode([Int].self, from: data)
        }
    }
}

extension Dictionary: MagicalSequence where Key: Codable, Value: MagicObject {
    static func allID(_ data: Data) throws -> [Int] {
        try Self.getAllID(data)
    }
}
