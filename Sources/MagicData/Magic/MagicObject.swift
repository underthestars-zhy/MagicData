//
//  MagicObject.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicObject {
    func createMirror() -> Mirror
    subscript(checkedMirrorDescendant key: String) -> Any { get }

    init()
}

extension MagicObject {
    func createMirror() -> Mirror {
        Mirror(reflecting: self)
    }

    subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }
}
