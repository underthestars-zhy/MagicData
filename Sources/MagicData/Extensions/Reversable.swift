//
//  Reversable.swift
//  
//
//  Created by 朱浩宇 on 2022/6/18.
//

import Foundation

public protocol Reversable {
    func isSequence() -> Bool
    var reversableID: UUID { get }
    func allID(_ data: Data) throws -> [Int]
}
