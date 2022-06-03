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
        if try tableExit(tableName(of: object)) { return }
        let mirror = object.createMirror()
        let expressions = mirror.createExpresses()
        let table = Table(tableName(of: object))

        try db.run(table.create(ifNotExists: true) { t in
            for expression in expressions {
                switch expression.type {
                case .string:
                    if expression.option {
                        t.column(Expression<String?>(expression.name))
                    } else {
                        t.column(Expression<String>(expression.name), primaryKey: expression.primary)
                    }
                }
            }
        })

        try addToTableInfo(object)
    }

    func tableName(of object: MagicObject) -> String {
        type(of: object).tableName
    }

    func addToTableInfo(_ object: MagicObject) throws {
        let info = Table("0Table_Info")
        let tableName = Expression<String>("table_name")
        let version = Expression<Int>("version")

        try db.run(info.insert(tableName <- self.tableName(of: object), version <- 0))
    }
}

