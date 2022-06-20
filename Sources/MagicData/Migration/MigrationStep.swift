//
//  MigrationStep.swift
//  
//
//  Created by 朱浩宇 on 2022/6/20.
//

import Foundation

public struct MigrationStep {
    let changes: [Changes]

    public init(changes: () -> [Changes]) {
        self.changes = changes()
    }
}
