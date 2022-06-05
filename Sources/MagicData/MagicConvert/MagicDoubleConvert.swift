//
//  MagicDoubleConvert.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

public protocol MagicDoubleConvert {
    static func create(_ value: Double?, magic: MagicData) async throws -> Self?
    func convert() -> Double
}
