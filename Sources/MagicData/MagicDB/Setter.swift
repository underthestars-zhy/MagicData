//
//  File.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation
import SQLite

extension MagicData {
    func createSetters(of object: MagicObject) throws -> [Setter] {
        return try object.createMirror().createExpresses().compactMap({ express in
            switch express.type {
            case .string:
                if express.option {
                    return (Expression<String?>(express.name) <- (express.value as? MagicStringConvert)?.convertToString())
                } else {
                    if let value = (express.value as? MagicStringConvert)?.convertToString() {
                        return (Expression<String?>(express.name) <- value)
                    } else {
                        throw MagicError.missValue
                    }
                }
            }
        })
    }
}
