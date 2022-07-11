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
            try await object.0.convert(magic: magic)
        }

        return try JSONEncoder().encode(list)
    }

    public var set: [(Element, Int?)]

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
        self.remove(element)
        self.set.append((element, MagicData.getZIndex(of: element)))
    }

    public mutating func remove(_ element: Element) {
        if let zIndex = element.createMirror().getAllHost().first?.zIndex {
            self.set.removeAll { object in
                object.1 == zIndex
            }
        } else if element.hasPrimaryValue, let primary = element.createMirror().getPrimaryValue() {
            self.set.removeAll { (object, _) in
                if object.hasPrimaryValue {
                    return object.createMirror().getPrimaryValue()?.equal(to: primary) ?? false
                } else {
                    return false
                }
            }
        } else {
            let dict = element.createMirror().getAllHostDictionary()
            self.set.removeAll { (object, _) in
                if MagicData.tableName(of: object) == MagicData.tableName(of: element) {
                    let dictionary = object.createMirror().getAllHostDictionary()

                    return dictionary.allSatisfy { (key: String, value: MagicalValueHost) in
                        dict[key] === value
                    }
                } else {
                    return false
                }
            }
        }
    }

    public mutating func removeAll(where perform: (Element) -> Bool) {
        self.set.removeAll { object in
            perform(object.0)
        }
    }

    public mutating func deduplication() {
        let _set = self.set
        self.set = []
        for item in _set {
            self.insert(item.0)
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
    public typealias Element = Element

    public func makeIterator() -> IndexingIterator<[Element]> {
        return self.set.map(\.0).makeIterator()
    }
}

// MARK: - Not Stable
extension MagicalSet: Collection {
    public typealias Index = Int

    public var startIndex: Index { self.set.startIndex }
    public var endIndex: Index { self.set.endIndex }

    public subscript(position: Index) -> Element {
        get {
            return self.set[position].0
        }
    }

    public func index(after i: Index) -> Index {
        return i + 1
    }
}

extension MagicalSet: BidirectionalCollection {
    public func index(before i: Index) -> Index {
        return i - 1
    }
}

extension MagicalSet: RandomAccessCollection {}
