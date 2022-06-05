//
//  MagicStringConvert.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicStringConvert {
    static func create(_ value: String?, magic: MagicData) async throws -> Self?
    func convert() -> String
}
