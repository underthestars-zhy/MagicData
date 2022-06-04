import Foundation
import SQLite

@MagicActor
public class MagicData {
    let db: Connection

    public convenience init() async throws {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
            throw MagicError.cannotCreateFile
        }

        try await self.init(path: url)
    }

    public init(path: URL) async throws {
        self.db = try await MagicDBHoster.shared.getDB(path: path)
        try createTableInfoTableIfNotExist()
    }

    public func update(_ object: MagicObject) throws {
        try createTable(object)
        // TODO: try updateTable(object)

        let table = Table(tableName(of: object))

        try db.run(table.insert(or: .replace, createSetters(of: object)))
    }

    public func object<Value: MagicObject>(of: Value.Type) throws -> [Value] {
        let table = Table("\(type(of: Value().self))")

        return try db.prepare(table).map { row in
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
                            host.set(value: convert.create(row[Expression<String?>(expression.name)]))
                        } else {
                            host.set(value: convert.create(row[Expression<String>(expression.name)]))
                        }
                    } else {
                        throw MagicError.connetConvertToMagicConvert
                    }
                case .int:
                    if let convert = host.type as? MagicIntConvert.Type {
                        if expression.option {
                            host.set(value: convert.create(row[Expression<Int?>(expression.name)]))
                        } else {
                            host.set(value: convert.create(row[Expression<Int>(expression.name)]))
                        }
                    } else {
                        throw MagicError.connetConvertToMagicConvert
                    }
                case .double:
                    if let convert = host.type as? MagicDoubleConvert.Type {
                        if expression.option {
                            host.set(value: convert.create(row[Expression<Double?>(expression.name)]))
                        } else {
                            host.set(value: convert.create(row[Expression<Double>(expression.name)]))
                        }
                    } else {
                        throw MagicError.connetConvertToMagicConvert
                    }
                case .data:
                    if let convert = host.type as? MagicDataConvert.Type {
                        if expression.option {
                            host.set(value: convert.create(row[Expression<Data?>(expression.name)]))
                        } else {
                            host.set(value: convert.create(row[Expression<Data>(expression.name)]))
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

actor MagicDBHoster {
    static let shared = MagicDBHoster()

    var dbs: [String : Connection] = [:]

    func getDB(path: URL) throws -> Connection {
        if let db = dbs[path.path] {
            return db
        } else {
            let connection = try Connection(path.appendingPathComponent("db.sqlite3").path)
            dbs[path.path] = connection
            return connection
        }
    }
}

@globalActor public actor MagicActor {
    public static let shared = MagicActor()
    private init() { }
}

