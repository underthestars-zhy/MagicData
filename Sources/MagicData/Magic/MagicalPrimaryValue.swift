//
//  MagicalPrimaryValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicalPrimaryValue: Equatable {
    static var deafultPrimaryValue: Self { get }
}

public typealias CombineMagicalPrimaryValueWithMagical = Magical & MagicalPrimaryValue

extension MagicalPrimaryValue {
    func equal(to value: any MagicalPrimaryValue) -> Bool {
        if let value = value as? Self {
            return value == self
        } else {
            return false
        }
    }
}
