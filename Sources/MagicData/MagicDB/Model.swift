//
//  Model.swift
//  
//
//  Created by 朱浩宇 on 2022/6/5.
//

import Foundation
import SQLite

extension MagicData {
    func createModel<Value: MagicObject>(by row: Row) async throws -> Value {
        let model = Value()
        let mirror = model.createMirror()
        for expression in mirror.createExpresses() {
            let keyPath = \Value.[checkedMirrorDescendant: expression.name] as PartialKeyPath<Value>
            let valueMirror = Mirror(reflecting: model[keyPath: keyPath])
            guard let host = valueMirror.getHost() else { throw MagicError.missHost }

            switch expression.type {
            case .string:
                if let convert = host.type as? MagicStringConvert.Type {
                    if expression.option {
                        try await host.set(value: convert.create(row[Expression<String?>(expression.name)], magic: self))
                    } else {
                        try await host.set(value: convert.create(row[Expression<String>(expression.name)], magic: self))
                    }
                } else {
                    throw MagicError.connetConvertToMagicConvert
                }
            case .int:
                if let convert = host.type as? MagicIntConvert.Type {
                    if expression.option {
                        try await host.set(value: convert.create(row[Expression<Int?>(expression.name)], magic: self))
                    } else {
                        try await host.set(value: convert.create(row[Expression<Int>(expression.name)], magic: self))
                    }
                } else {
                    throw MagicError.connetConvertToMagicConvert
                }
            case .double:
                if let convert = host.type as? MagicDoubleConvert.Type {
                    if expression.option {
                        try await host.set(value: convert.create(row[Expression<Double?>(expression.name)], magic: self))
                    } else {
                        try await host.set(value: convert.create(row[Expression<Double>(expression.name)], magic: self))
                    }
                } else {
                    throw MagicError.connetConvertToMagicConvert
                }
            case .data:
                if let convert = host.type as? MagicDataConvert.Type {
                    if expression.option {
                        try await host.set(value: convert.create(row[Expression<Data?>(expression.name)], magic: self))
                    } else {
                        try await host.set(value: convert.create(row[Expression<Data>(expression.name)], magic: self))
                    }
                } else {
                    throw MagicError.connetConvertToMagicConvert
                }
            }
        }

        return model
    }
}
