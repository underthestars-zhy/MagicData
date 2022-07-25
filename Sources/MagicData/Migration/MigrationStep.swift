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

    func modifyRow(_ row: Row) -> Row {
        var row = row
        for change in changes {
            switch change {
            case .add(let name):
                break
            case .delete(let name):
                break
            }
        }

        return row
    }
}
