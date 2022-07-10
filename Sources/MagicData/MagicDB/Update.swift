//
//  Update.swift
//  
//
//  Created by 朱浩宇 on 2022/6/20.
//

import Foundation
import SQLite

extension MagicData {
    func check(_ object: MagicObject, row: Row) throws -> Bool {
        let originalStruct = row[Expression<Data>("structure")]
        if originalStruct != (try getModelStruct(object)) {
            fatalError("The sturcture of objec has changes, but there isn't any migration.")
        }
        return object.createMigrations().needUpdate(row[Expression<Int>("version")]) || row[Expression<Bool>("updating")]
    }

    func onlyCheckUpdateStatus(row: Row) -> Bool {
        row[Expression<Bool>("updating")]
    }

    func removeBackup(_ object: MagicObject) throws {
        let name = Self.tableName(of: object)
        let backupName = "\(name)-Backup"

        try db.run(Table(backupName).delete())
    }

    func setInfoToUpdating(_ object: MagicObject) throws {
        let table = Table(Self.tableName(of: object))

        try db.run(table.where(Expression<String>("table_name") == Self.tableName(of: object)).update(Expression<Bool>("updating") <- true))
    }

    func update(_ object: MagicObject, row: Row) throws {
        let name = Self.tableName(of: object)
        let backupName = "\(name)-Backup"
        let migrations = object.createMigrations()

        if try check(object, row: row) {
            if !onlyCheckUpdateStatus(row: row) {
                try removeBackup(object)

                try db.run(Table(name).rename(Table(backupName)))
            }

            try setInfoToUpdating(object)

            try dropTable(object)

            try createTable(object, addToInfo: false)

            let rows = try getRows(.init(backupName))

            for row in rows {
//                let newRow = migrations.r2r(row)
            }
        }
    }
}
