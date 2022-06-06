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

    public func update(_ object: MagicObject) async throws {
        try createTable(object)
        // TODO: try updateTable(object)

        let table = Table(tableName(of: object))

        if object.hasPrimaryValue {
            guard let primaryExpress = object.createMirror().createExpresses().first(where: { express in
                express.primary
            }) else {
                throw MagicError.missPrimary
            }

            guard let primaryValue = object.createMirror().getValue(by: primaryExpress) as? CombineMagicalPrimaryValueWithMagical else { throw MagicError.missPrimary  }
            

            if try await has(of: type(of: object), primary: primaryValue) {
                let query: Table

                switch primaryExpress.type {
                case .string:
                    guard let primaryValue = try await (primaryValue as? MagicStringConvert)?.convert(magic: self) else { throw MagicError.missPrimary }
                    query = table.where(Expression<String>(primaryExpress.name) == primaryValue)
                case .int:
                    guard let primaryValue = try await (primaryValue as? MagicIntConvert)?.convert(magic: self) else { throw MagicError.missPrimary }
                    query = table.where(Expression<Int>(primaryExpress.name) == primaryValue)
                default:
                    throw MagicError.missPrimary
                }

                try await db.run(query.update(createSetters(of: object)))
            } else {
                try await db.run(table.insert(or: .replace, createSetters(of: object) + [(Expression<Int>("z_index") <- getZIndexAndUpdate(object))]))
            }
        } else {
            try await db.run(table.insert(or: .replace, createSetters(of: object) + [(Expression<Int>("z_index") <- getZIndexAndUpdate(object))]))
        }
    }

    public func has(of value: MagicObject.Type, primary: CombineMagicalPrimaryValueWithMagical) async throws -> Bool {
        guard value.init().hasPrimaryValue else { throw MagicError.missPrimary }
        guard let primaryExpress = value.init().createMirror().createExpresses().first(where: { express in
            express.primary
        }) else {
            throw MagicError.missPrimary
        }

        try createTable(value.init())
        // TODO: try updateTable(object)

        let table = Table("\(type(of: value.init().self))")
        let query: Table

        switch primaryExpress.type {
        case .string:
            guard let primaryValue = try await (primary as? MagicStringConvert)?.convert(magic: self) else { throw MagicError.missPrimary }
            query = table.where(Expression<String>(primaryExpress.name) == primaryValue)
        case .int:
            guard let primaryValue = try await (primary as? MagicIntConvert)?.convert(magic: self) else { throw MagicError.missPrimary }
            query = table.where(Expression<Int>(primaryExpress.name) == primaryValue)
        default:
            throw MagicError.missPrimary
        }

        return try db.scalar(query.count) == 1
    }

    public func object<Value: MagicObject, Primary: CombineMagicalPrimaryValueWithMagical>(of: Value.Type, primary: Primary) async throws -> Value {
        guard Value().hasPrimaryValue else { throw MagicError.missPrimary }
        guard let primaryExpress = Value().createMirror().createExpresses().first(where: { express in
            express.primary
        }) else {
            throw MagicError.missPrimary
        }

        try createTable(Value())
        // TODO: try updateTable(object)

        let table = Table("\(type(of: Value().self))")
        let query: Table

        switch primaryExpress.type {
        case .string:
            guard let primaryValue = try await (primary as? MagicStringConvert)?.convert(magic: self) else { throw MagicError.missPrimary }
            query = table.where(Expression<String>(primaryExpress.name) == primaryValue)
        case .int:
            guard let primaryValue = try await (primary as? MagicIntConvert)?.convert(magic: self) else { throw MagicError.missPrimary }
            query = table.where(Expression<Int>(primaryExpress.name) == primaryValue)
        default:
            throw MagicError.missPrimary
        }

        guard let row = try db.pluck(query) else { throw MagicError.cannotFindValue }

        return try await self.createModel(by: row)
    }

    public func object<Value: MagicObject>(of: Value.Type) async throws -> [Value] {
        try createTable(Value())
        // TODO: try updateTable(object)

        let table = Table("\(type(of: Value().self))")

        return try await db.prepare(table).asyncMap { row in
            return try await self.createModel(by: row)
        }
    }
}


@globalActor public actor MagicActor {
    public static let shared = MagicActor()
    private init() { }
}

