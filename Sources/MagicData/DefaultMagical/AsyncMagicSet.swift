//
//  AsyncMagicSet.swift
//  
//
//  Created by 朱浩宇 on 2022/6/11.
//

import Foundation

public protocol _AsyncMagicalSet {
    init(_ ids: [Int], magic: MagicData)
    init()
}

public struct AsyncReverseMagicSet<Element>: _AsyncMagicalSet where Element: MagicObject {
    private let ids: Set<Int>
    private let magic: MagicData?

    public init(_ ids: [Int], magic: MagicData) {
        self.ids = Set(ids)
        self.magic = magic
    }

    public init() {
        self.ids = []
        self.magic = nil
    }
}

public extension AsyncReverseMagicSet {
    static func == (lhs: AsyncReverseMagicSet<Element>, rhs: AsyncReverseMagicSet<Element>) -> Bool {
        return lhs.ids == rhs.ids
    }
}

extension AsyncReverseMagicSet: AsyncSequence {
    public typealias Element = Element

    public struct AsyncIterator : AsyncIteratorProtocol {
        var ids: [Int]
        let magic: MagicData?
        mutating public func next() async throws -> Element? {
            guard let magic else { return nil }
            try Task.checkCancellation()

            guard !ids.isEmpty else { return nil }
            let id = ids.removeFirst()

            return try await magic.getObject(by: id)
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(ids: ids.map { $0 }, magic: magic)
    }
}

public extension AsyncReverseMagicSet {
    var count: Int {
        ids.count
    }
}
