import Foundation
import SQLite
import CollectionConcurrencyKit

@MagicActor
public class MagicData {
    let db: Connection
    let filePath: URL
    let tempory: Bool

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

        self.filePath = try Self.createPath(nil)
        self.tempory = true

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

        self.filePath = try Self.createPath(path)
        self.tempory = false

        try createTableInfoTableIfNotExist()
    }

    deinit {
        if tempory {
            try? FileManager.default.removeItem(at: filePath)
        }
    }

    static func createPath(_ path: URL?) throws -> URL {
        if let path {
            let url = path.universalAppending(path: "files")
            
            if !FileManager.default.fileExists(atPath: url.universalPath()) {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            }

            return url
        } else {
            #if os(macOS)
            guard let url = FileManager.default.urls(for: .downloadsDirectory, in: .allDomainsMask).first?.universalAppending(path: "files") else {
                throw MagicError.cannotCreateFile
            }
            #else
            guard let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first?.universalAppending(path: "files") else {
                throw MagicError.cannotCreateFile
            }
            #endif

            if !FileManager.default.fileExists(atPath: url.universalPath()) {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            }

            return url
        }
    }

    @discardableResult
    public func update(_ object: some MagicObject) async throws -> Int {
        try createTable(object)
        // TODO: try updateTable(object)

        let table = Table(Self.tableName(of: object))

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

                if let _zIndex = Self.getZIndex(of: object) {
                    zIndex = _zIndex
                } else if let _zIndex = Self.getZIndex(of: try await self.object(of: type(of: object), primary: primaryValue)) {
                    zIndex = _zIndex
                } else {
                    throw MagicError.missZIndex
                }

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

    public func remove(_ object: some MagicObject) throws {
        try createTable(object)
        // TODO: try updateTable(object)

        let table = Table(Self.tableName(of: object))

        guard let zIndex = Self.getZIndex(of: object) else { throw MagicError.objectHasNotSaved }

        let query = table.where(Expression<Int>("z_index") == zIndex)

        try db.run(query.delete())
    }

    public func removeAll(of type: any MagicObject.Type) throws {
        try createTable(type.init())
        // TODO: try updateTable(object)

        let table = Table(Self.tableName(of: type.init()))

        try db.run(table.delete())
    }

    public func check(of type: any MagicObject.Type) throws -> Bool {
        let object = type.init()
        try createTable(object)

        guard let row = try getTableInfo(of: type) else {
            throw MagicError.cannotGetTableInfo
        }

        return try check(object, row: row)
    }
}


@globalActor public actor MagicActor {
    public static let shared = MagicActor()
    private init() { }
}
