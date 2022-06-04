//
//  MagicIntConvert.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

public protocol MagicIntConvert {
    static func create(_ value: Int?) -> Self?
    func convert() -> Int
}
