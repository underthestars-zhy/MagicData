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

struct AsyncMagicSet<Element>: _AsyncMagicalSet where Element: MagicObject {
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

extension AsyncMagicSet {
    public static func == (lhs: AsyncMagicSet<Element>, rhs: AsyncMagicSet<Element>) -> Bool {
        return lhs.ids == rhs.ids
    }
}

extension AsyncMagicSet: AsyncSequence {
    typealias Element = Element

    struct AsyncIterator : AsyncIteratorProtocol {
        var ids: [Int]
        let magic: MagicData?
        mutating func next() async throws -> Element? {
            print(ids)
            guard let magic else { return nil }
            try Task.checkCancellation()

            guard !ids.isEmpty else { return nil }
            let id = ids.removeFirst()

            return try await magic.getObject(by: id)
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(ids: ids, magic: magic)
    }
}

extension AsyncMagicSet {
    var count: Int {
        ids.count
    }
}
