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

    @discardableResult
    public func update(_ object: some MagicObject) async throws -> Int {
        try createTable(object)
        // TODO: try updateTable(object)

        let table = Table(tableName(of: object))

        let zIndex: Int

        if object.hasPrimaryValue {
            guard let primaryExpress = object.createMirror().createExpresses().first(where: { express in
                express.primary
            }) else {
                throw MagicError.missPrimary
            }

            guard let primaryValue = object.createMirror().getValue(by: primaryExpress) as? any CombineMagicalPrimaryValueWithMagical else { throw MagicError.missPrimary  }
            

            if try await has(of: type(of: object), primary: primaryValue) {
                let query: Table = try await createQueryTable(primaryExpress, primary: primaryValue, table: table)

                try await db.run(query.update(createSetters(of: object)))

                try await zIndex = getZIndex(of: object)
            } else {
                zIndex = try getZIndexAndUpdate(object)
                try await db.run(table.insert(or: .replace, createSetters(of: object) + [(Expression<Int>("z_index") <- zIndex)]))
            }
        } else if let index = object.createMirror().getAllHost().first?.zIndex {
            zIndex = index

            let query = table.where(Expression<Int>("z_index") == zIndex)
            try db.run(await query.update(try createSetters(of: object)))
        } else {
            zIndex = try getZIndexAndUpdate(object)
            try await db.run(table.insert(or: .replace, createSetters(of: object) + [(Expression<Int>("z_index") <- zIndex)]))
        }

        object.createMirror().getAllHost().forEach { host in
            host.zIndex = zIndex
        }

        return zIndex
    }

    public func has(of value: any MagicObject.Type, primary: any CombineMagicalPrimaryValueWithMagical) async throws -> Bool {
        guard value.init().hasPrimaryValue else { throw MagicError.missPrimary }
        guard let primaryExpress = value.init().createMirror().createExpresses().first(where: { express in
            express.primary
        }) else {
            throw MagicError.missPrimary
        }

        try createTable(value.init())
        // TODO: try updateTable(object)

        let table = Table("\(type(of: value.init().self))")
        let query: Table = try await createQueryTable(primaryExpress, primary: primary, table: table)

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

    public func delete(_ object: some MagicObject) async throws {
        try createTable(object)
        // TODO: try updateTable(object)
    }
}


@globalActor public actor MagicActor {
    public static let shared = MagicActor()
    private init() { }
}
