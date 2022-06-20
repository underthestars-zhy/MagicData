//
//  MigrationStepResultBuilder.swift
//  
//
//  Created by 朱浩宇 on 2022/6/20.
//

import Foundation

@resultBuilder
public struct MigrationStepResultBuilder {
    public static func buildBlock(_ components: MigrationStep...) -> [MigrationStep] {
        components
    }
}
