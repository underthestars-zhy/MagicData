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
        let table = Table("\(type(of: Value.self))")

//        return try db.prepare(table).map { row in
//            let model = Value()
//            let mirror = model.createMirror()
//            for expression in mirror.createExpresses() {
//                if let keyPath = mirror.descendant(expression.name) as? PartialKeyPath<Value> {
//                    switch expression.type {
//                    case .string:
//                        if expression.option {
//                            let value = row[Expression<String?>(expression.name)]
//                            model[keyPath: keyPath] = value
//                        } else {
//                            let value = row[Expression<String>(expression.name)]
//                        }
//                    }
//                }
//            }
//
//            return model
//        }

        return []
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

