//
//  Row.swift
//  
//
//  Created by 朱浩宇 on 2022/6/20.
//

import Foundation
import SQLite

extension Row {
    var _columnNames: [String: Int] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first { (label: String?, value: Any) in
            label == "columnNames"
        }?.value as! [String: Int]
    }

    var _values: [Binding?] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first { (label: String?, value: Any) in
            label == "columnNames"
        }?.value as! [Binding?]
    }
}
