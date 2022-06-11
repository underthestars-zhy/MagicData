//
//  Sqlite.swift
//  
//
//  Created by 朱浩宇 on 2022/6/11.
//

import Foundation
import SQLite

extension MagicData {
    func row<Value: MagicObject>(of: Value.Type) async throws -> [Row] {
        try createTable(Value())
        // TODO: try updateTable(object)

        let table = Table("\(type(of: Value().self))")

        return try db.prepare(table).map { $0 }
    }
}
