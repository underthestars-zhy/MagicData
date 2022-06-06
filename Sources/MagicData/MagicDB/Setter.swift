//
//  File.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation
import SQLite
import CollectionConcurrencyKit

extension MagicData {
    func createSetters(of object: MagicObject) async throws -> [Setter] {
        return try await object.createMirror().createExpresses().asyncCompactMap({ express in
            switch express.type {
            case .string:
                if express.option {
                    return try await (Expression<String?>(express.name) <- (express.value as? MagicStringConvert)?.convert(magic: self))
                } else {
                    if let value = try await (express.value as? MagicStringConvert)?.convert(magic: self) {
                        return (Expression<String>(express.name) <- value)
                    } else {
                        throw MagicError.missValue
                    }
                }
            case .int:
                if express.option {
                    return try await (Expression<Int?>(express.name) <- (express.value as? MagicIntConvert)?.convert(magic: self, object: object))
                } else {
                    if express.auto {
                        return nil
                    } else if let value = try await (express.value as? MagicIntConvert)?.convert(magic: self, object: object) {
                        return (Expression<Int>(express.name) <- value)
                    } else {
                        throw MagicError.missValue
                    }
                }
            case .double:
                if express.option {
                    return try await (Expression<Double?>(express.name) <- (express.value as? MagicDoubleConvert)?.convert(magic: self))
                } else {
                    if let value = try await (express.value as? MagicDoubleConvert)?.convert(magic: self) {
                        return (Expression<Double>(express.name) <- value)
                    } else {
                        throw MagicError.missValue
                    }
                }
            case .data:
                if express.option {
                    return try await (Expression<Data?>(express.name) <- (express.value as? MagicDataConvert)?.convert(magic: self))
                } else {
                    if let value = try await (express.value as? MagicDataConvert)?.convert(magic: self) {
                        return (Expression<Data>(express.name) <- value)
                    } else {
                        throw MagicError.missValue
                    }
                }
            }
        })
    }
}
