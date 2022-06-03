//
//  MagicObject.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicObject {
    static var tableName: String { get }
    func createMirror() -> Mirror
}

extension MagicObject {
    func createMirror() -> Mirror {
        Mirror(reflecting: self)
    }

    static var tableName: String {
        "\(Self.self)"
    }
}
