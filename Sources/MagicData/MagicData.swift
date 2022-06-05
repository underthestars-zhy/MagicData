import Foundation
import SQLite
import CollectionConcurrencyKit

@MagicActor
public class MagicData {
    let db: Connection

    public enum CreateType {
        case memory
        case temporary
    }

    public init(type: CreateType) throws {
        switch type {
        case .memory:
            self.db = try Connection()
        case .temporary:
            self.db = try Connection(.temporary)
        }

        try createTableInfoTableIfNotExist()
    }

    public convenience init() throws {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
            throw MagicError.cannotCreateFile
        }

        try self.init(path: url)
    }

    public init(path: URL) throws {
        self.db = try Connection(path.appendingPathComponent("default.sqlite3").path)
        try createTableInfoTableIfNotExist()
    }

    public func update(_ object: MagicObject) throws {
        try createTable(object)
        // TODO: try updateTable(object)

        let table = Table(tableName(of: object))

        try db.run(table.insert(or: .replace, createSetters(of: object)))
    }

    public func object<Value: MagicObject>(of: Value.Type) async throws -> [Value] {
        try createTable(Value())
        // TODO: try updateTable(object)

        let table = Table("\(type(of: Value().self))")

        return try await db.prepare(table).asyncMap { row in
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
}


@globalActor public actor MagicActor {
    public static let shared = MagicActor()
    private init() { }
}

