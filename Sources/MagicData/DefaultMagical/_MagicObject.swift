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

//        let allReversable: [KeyPath<Magical, Reversable>] = self.createMirror().findAllReversable().compactMap { r in
//            let mirror = Mirror(reflecting: r)
//            let type = mirror.children.first { (label: String?, value: Any) in
//                label == "objectType"
//            }
//        }
//
//        print(allReversable.count)

        try await magic.update(self)

        let zIndex = try await magic.getZIndex(of: self)

        return zIndex
    }
}
