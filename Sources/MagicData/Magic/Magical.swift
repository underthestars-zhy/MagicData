//
//  Magical.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol Magical: Codable {
    static var type: MagicalType { get }
}
