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

            host.zIndex = row[Expression<Int>("z_index")]
        }

        let allReverse = model.createMirror().getAllReverse()

        guard let zIndex = model.createMirror().getAllHost().first?.zIndex else { throw MagicError.missValue }

        for reverse in allReverse {
            let reverseMirror = Mirror(reflecting: reverse)
            guard let idHost = reverseMirror.getIDHost() else { continue }

            idHost.zIndex = zIndex

            guard let type = reverseMirror.getType() else { continue }
            let _object = type.init()
            let rows = try await self.row(of: type)
            guard let reversable = reverse.createProjectValue(_object) else { continue }
            guard let name = _object.createMirror().children.first(where: { (label: String?, value: Any) in
                (value as? Reversable)?.reversableID == reversable.reversableID
            })?.label else { continue }

            var ids = [Int]()

            for row in rows {
                let _zIndex = row[Expression<Int>("z_index")]
                if reversable.isSequence() {
                    guard let data = row[Expression<Data?>(name)] else { continue }
                    if try reversable.allID(data).contains(zIndex) {
                        ids.append(_zIndex)
                    }
                } else {
                    guard let int = row[Expression<Int?>(name)] else { continue }
                    if int == zIndex {
                        ids.append(_zIndex)
                    }
                }
            }

            idHost.setValue(ids, magic: self)
        }

        return model
    }
}
