//
//  Magical.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol Magical {
    static var defualtValue: Self? { get }
    static var type: MagicalType { get }
}

public extension Magical {
    static var defualtValue: Self? {
        nil
    }
}
