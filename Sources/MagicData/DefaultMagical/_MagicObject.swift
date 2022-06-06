//
//  MagicObject.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

extension MagicObject {
    static func create(_ value: Int?, magic: MagicData) async throws -> Self? {
        if let value = value {
            return try await magic.getObject(by: value)
        } else {
            return nil
        }
    }

    static var type: MagicalType {
        return .int
    }

    func convert(magic: MagicData) async throws -> Int {
        guard self.hasPrimaryValue else { throw MagicError.missPrimary }

        let allReversable = self.createMirror().findAllReversable()

        try await magic.update(self)

        let zIndex = try await magic.getZIndexOfObject(self) - 1

        return zIndex
    }
}
