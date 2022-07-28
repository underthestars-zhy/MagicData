//
//  MigrationStep.swift
//  
//
//  Created by 朱浩宇 on 2022/6/20.
//

import Foundation
import SQLite

public struct MigrationStep {
    let changes: [Changes]

    public init(changes: () -> [Changes]) {
        self.changes = changes()
    }

    func modifyRow(_ row: Row) throws -> Row {
        var row = row
        for change in changes {
            switch change {
            case .addOptionalValue(let name):
                break
            case .deleteValue(let name):
                if let idx = row._columnNames[name] {
                    let newColumNames = row._columnNames.filter { element in
                        element.key != name
                    }
                    var newValues = row._values
                    newValues.remove(at: idx)
                    row = Row(newColumNames, newValues)
                } else {
                    throw MagicError.cannotFindValueInRow(name: name)
                }
            }
        }

        return row
    }
}
