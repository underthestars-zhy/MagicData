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

