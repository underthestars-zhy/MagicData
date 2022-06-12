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

            return .init(list)
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

    public var set: [Element]

    public init(_ sequence: some Sequence<Element>) {
        self.set = []
        for item in sequence {
            self.insert(item)
        }
    }

    public init() {
        self.set = []
    }

    public mutating func insert(_ element: Element) {
        if let zIndex = element.createMirror().getAllHost().first?.zIndex {
            if !self.set.contains(where: { object in
                object.createMirror().getAllHost().first?.zIndex == zIndex
            }) {
                self.set.append(element)
            }
        } else {
            self.set.append(element)
        }
    }

    public mutating func remove(_ element: Element) {
        if let zIndex = element.createMirror().getAllHost().first?.zIndex {
            self.set.removeAll { object in
                object.createMirror().getAllHost().first?.zIndex == zIndex
            }
        }
    }

    public mutating func removeAll(where perform: (Element) -> Bool) {
        self.set.removeAll { object in
            perform(object)
        }
    }

    public mutating func deduplication() {
        let _set = self.set
        self.set = []
        for item in _set {
            self.insert(item)
        }
    }
}

extension MagicalSet: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.set = []
        for item in elements {
            self.insert(item)
        }
    }

    public typealias ArrayLiteralElement = Element
}

extension MagicalSet: Sequence {
    public func makeIterator() -> IndexingIterator<[Element]> {
        return self.set.makeIterator()
    }
}
