//
//  MagicObject.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicObject: Magical, MagicIntConvert, Codable, AsyncMagicalHostable {
    func createMirror() -> Mirror
    subscript(checkedMirrorDescendant key: String) -> Any { get }
    var hasPrimaryValue: Bool { get }

    init()
}

public extension MagicObject {
    func createMirror() -> Mirror {
        Mirror(reflecting: self)
    }

    subscript(checkedMirrorDescendant key: String) -> Any {
        return Mirror(reflecting: self).descendant(key)!
    }

    var hasPrimaryValue: Bool {
        let mirror = self.createMirror()
        return mirror.children.contains { (label: String?, value: Any) in
            let _mirror = Mirror(reflecting: value)
            return "\(_mirror.subjectType)".hasPrefix("PrimaryMagicValue")
        }
    }
}
