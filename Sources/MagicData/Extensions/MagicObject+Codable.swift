//
//  File.swift
//  
//
//  Created by 朱浩宇 on 2022/6/13.
//

import Foundation

public extension MagicObject {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = MagicData.getZIndex(of: self) {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }

    init(from decoder: Decoder) throws {
        fatalError()
    }
}
