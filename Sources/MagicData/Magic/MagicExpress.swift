//
//  MagicExpress.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

struct MagicExpress {
    let name: String
    let primary: Bool
    let option: Bool
    let type: MagicalType
    let value: (any Magical)?
    let auto: Bool
    let zIndex: Int
}
