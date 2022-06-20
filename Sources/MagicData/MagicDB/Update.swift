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
}
