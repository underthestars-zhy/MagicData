//
//  MagicObject.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicObject {
    var name: String { get }
    func createMirror() -> Mirror
}

extension MagicObject {
    var name: String {
        "\(Self.self)"
    }

    func createMirror() -> Mirror {
        return Mirror(reflecting: self)
    }
}
