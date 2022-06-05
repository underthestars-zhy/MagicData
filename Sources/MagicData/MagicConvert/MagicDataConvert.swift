//
//  MagicDataConvert.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

public protocol MagicDataConvert {
    static func create(_ value: Data?, magic: MagicData) async throws -> Self?
    func convert(magic: MagicData) async throws -> Data
}
