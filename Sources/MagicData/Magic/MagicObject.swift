//
//  MagicObject.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

protocol _MagicObject {
    func createMirror() -> Mirror
}

extension _MagicObject {
    func createMirror() -> Mirror {
        Mirror(reflecting: self)
    }
}

public class MagicObject: NSObject, _MagicObject {
    override public init() {
        super.init()
    }
}
