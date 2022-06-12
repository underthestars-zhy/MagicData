//
//  MagicaSet.swift
//  
//
//  Created by 朱浩宇 on 2022/6/11.
//

import Foundation

public struct MagicalSet<Element>: Magical, MagicDataConvert where Element: MagicObject {
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

extension MagicalSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.set = Set<Element>(elements)
    }

    public typealias ArrayLiteralElement = Element
}


public extension MagicalSet {
    static func == (lhs: MagicalSet<Element>, rhs: MagicalSet<Element>) -> Bool {
        return lhs.set == rhs.set
    }
}

extension MagicalSet: Sequence {
    public func makeIterator() -> some IteratorProtocol {
        return set.makeIterator()
    }
}
