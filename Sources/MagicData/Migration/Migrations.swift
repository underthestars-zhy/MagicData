//
//  Migrations.swift
//  
//
//  Created by 朱浩宇 on 2022/6/20.
//

import Foundation

public struct Migrations {
    let steps: [MigrationStep]

    public init() {
        self.steps = []
    }

    public init(_ steps: [MigrationStep]) {
        self.steps = steps
    }

    public init(_ steps: MigrationStep...) {
        self.steps = steps
    }

    public init(@MigrationStepResultBuilder _ steps: () -> [MigrationStep]) {
        self.steps = steps()
    }

    func needUpdate(_ version: Int) -> Bool {
        steps.count - 1 == version
    }
}
