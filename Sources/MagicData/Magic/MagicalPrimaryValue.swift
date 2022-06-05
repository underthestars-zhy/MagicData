//
//  MagicalPrimaryValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol MagicalPrimaryValue {
    static var deafultPrimaryValue: Self { get }
}

public typealias CombineMagicalPrimaryValueWithMagical = Magical & MagicalPrimaryValue
