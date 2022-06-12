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

public struct AsyncMagicSet<Element>: _AsyncMagicalSet where Element: MagicObject {
    private let ids: [Int]
    private let magic: MagicData?

    public init(_ ids: [Int], magic: MagicData) {
        self.ids = ids
        self.magic = magic
    }

    public init() {
        self.ids = []
        self.magic = nil
    }
}

public extension AsyncMagicSet {
    static func == (lhs: AsyncMagicSet<Element>, rhs: AsyncMagicSet<Element>) -> Bool {
        return lhs.ids == rhs.ids
    }
}

extension AsyncMagicSet: AsyncSequence {
    public typealias Element = Element

    public struct AsyncIterator : AsyncIteratorProtocol {
        var ids: [Int]
        let magic: MagicData?
        mutating public func next() async throws -> Element? {
            print(ids)
            guard let magic else { return nil }
            try Task.checkCancellation()

            guard !ids.isEmpty else { return nil }
            let id = ids.removeFirst()

            return try await magic.getObject(by: id)
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(ids: ids, magic: magic)
    }
}

public extension AsyncMagicSet {
    var count: Int {
        ids.count
    }
}
