//
//  MagicDataConvert.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

public protocol MagicDataConvert {
    static func create(_ value: Data?) -> Self?
    func convert() -> Data
}
