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
        let zIndexCount = Expression<Int>("z_index_count")

        try db.run(info.create(ifNotExists: true) { t in
            t.column(tableName, primaryKey: true)
            t.column(version)
            t.column(zIndexCount)
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

    func createTable(_ object: some MagicObject) throws {
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
                case .int:
                    if expression.option {
                        t.column(Expression<Int?>(expression.name))
                    } else {
                        if expression.primary {
                            t.column(Expression<Int>(expression.name), primaryKey: .autoincrement)
                        } else {
                            t.column(Expression<Int>(expression.name), primaryKey: false)
                        }
                    }
                case .double:
                    if expression.option {
                        t.column(Expression<Double?>(expression.name))
                    } else {
                        t.column(Expression<Double>(expression.name), primaryKey: expression.primary)
                    }
                case .data:
                    if expression.option {
                        t.column(Expression<Data?>(expression.name))
                    } else {
                        t.column(Expression<Data>(expression.name), primaryKey: expression.primary)
                    }
                }
            }

            t.column(Expression<Int>("z_index"), unique: true)
        })

        try addToTableInfo(object)
    }

    func tableName(of object: some MagicObject) -> String {
        return "\(type(of: object))"
    }

    func addToTableInfo(_ object: some MagicObject) throws {
        let info = Table("0Table_Info")
        let tableName = Expression<String>("table_name")
        let version = Expression<Int>("version")
        let zIndexCount = Expression<Int>("z_index_count")

        try db.run(info.insert(tableName <- self.tableName(of: object), version <- 0, zIndexCount <- 0))
    }

    func getZIndexOfObject(_ object: some MagicObject) throws -> Int {
        let zindex = Expression<Int>("z_index_count")
        let tableName = Expression<String>("table_name")
        let name = self.tableName(of: object)

        let query = Table("0Table_Info").select(zindex).where(tableName == name)

        guard let res = try db.pluck(query) else { throw MagicError.cannotFindZIndex }

        return res[zindex]
    }

    func getZIndex(of object: some MagicObject) -> Int? {
        object.createMirror().getAllHost().first { host in
            host.zIndex != nil
        }?.zIndex
    }

    func addZindex(_ object: some MagicObject, orginial: Int) throws {
        let zindex = Expression<Int>("z_index_count")
        let tableName = Expression<String>("table_name")
        let name = self.tableName(of: object)

        let update = Table("0Table_Info").where(tableName == name).update(zindex <- orginial + 1)

        try db.run(update)
    }

    func getZIndexAndUpdate(_ object: some MagicObject) throws -> Int {
        let zIndex = try getZIndexOfObject(object)
        try addZindex(object, orginial: zIndex)

        return zIndex
    }

    func getObject<Object: MagicObject>(by zIndex: Int) async throws -> Object? {
        let table = Table(tableName(of: Object()))

        guard let row = try db.pluck(table.where(Expression<Int>("z_index") == zIndex)) else { return nil }

        return try await createModel(by: row)
    }

    func createQueryTable(_ primaryExpress: MagicExpress, primary: MagicalPrimaryValue, table: Table) async throws -> Table {
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

        return query
    }
}

