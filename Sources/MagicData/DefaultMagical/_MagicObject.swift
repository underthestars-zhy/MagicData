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

    func convert(magic: MagicData, object: MagicObject?) async throws -> Int {
        guard let object = object else {
            throw MagicError.missObject
        }

        guard self.hasPrimaryValue else { throw MagicError.missPrimary }

        let allReversable: [AnyKeyPath] = self.createMirror().findAllReversable().compactMap { r in
            let mirror = Mirror(reflecting: r)

            return mirror.children.first { (label: String?, value: Any) in
                label == "reverse"
            }?.value as? AnyKeyPath
        }

        for reversable in allReversable {

        }

        try await magic.update(self)

        let zIndex = try await magic.getZIndex(of: self)

        return zIndex
    }
}
