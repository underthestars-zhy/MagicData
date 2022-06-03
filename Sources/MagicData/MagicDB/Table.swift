//
//  File.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation
import SQLite

extension MagicData {
    func createTableInfoTableIfNotExist() throws {
        let info = Table("0Table_Info")

        let tableName = Expression<String>("table_name")
        let version = Expression<Int>("version")

        try db.run(info.create(ifNotExists: true) { t in
            t.column(tableName, primaryKey: true)
            t.column(version)
        })
    }

    func getAllTable() throws -> [String] {
        let info = Table("0Table_Info")

        let tableName = Expression<String>("table_name")

        return try db.prepare(info.select(tableName)).map {
            $0[tableName]
        }
    }

    func tableExit(_ tableName: String) throws -> Bool {
        try getAllTable().contains(tableName)
    }

    func createTable(_ object: MagicObject) throws {
        if try tableExit(object.name) { return }
        let mirror = object.createMirror()
        let expressions = mirror.createExpresses()
    }
}

