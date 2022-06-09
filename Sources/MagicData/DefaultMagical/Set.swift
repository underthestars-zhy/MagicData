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
        if Element.self is any Magical {
            throw MagicError.magicalCannotInArraryOrDictionary
        }

        return try JSONEncoder().encode(self)
    }
}

public struct MagicalSet<Element>: Magical, MagicDataConvert where Element: MagicObject {
    public static func == (lhs: MagicalSet<Element>, rhs: MagicalSet<Element>) -> Bool {
        return lhs.set == rhs.set
    }

    public static var type: MagicalType {
        return .data
    }

    public static func create(_ value: Data?, magic: MagicData) async throws -> MagicalSet<Element>? {
        if let value {
            let list = try await JSONDecoder().decode(Set<Int>.self, from: value).asyncCompactMap({ int in
                try await Element.create(int, magic: magic)
            })

            return .init(set: Set<Element>(list))
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> Data {
        let list = try await set.asyncMap { object in
            try await object.convert(magic: magic)
        }

        print(list)

        return try JSONEncoder().encode(list)
    }

    public var set: Set<Element>

    public init(_ sequence: some Sequence<Element>) {
        self.set = .init(sequence)
    }

    public init(set: Set<Element>) {
        self.set = set
    }

    public init() {
        self.set = []
    }

    public mutating func insert(_ element: Element) {
        self.set.insert(element)
    }

    public mutating func remove(_ element: Element) {
        self.set.remove(element)
    }
}
