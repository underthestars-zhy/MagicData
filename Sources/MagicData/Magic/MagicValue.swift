//
//  MagicValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

protocol _MagicValue {
    associatedtype Value: Magical
    var wrappedValue: Value { get set }
    var primary: Bool { get }
}

@propertyWrapper struct PrimaryMagicValue<Value: Magical>: _MagicValue where Value: MagicalPrimaryValue {
    public var wrappedValue: Value
    internal let primary: Bool = true

    public init() {
        self.wrappedValue = Value.deafult
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: _MagicValue {
    public var wrappedValue: Value
    internal let primary: Bool = false

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper public struct OptionMagicValue<Value: Magical> {
    public var wrappedValue: Value?
    internal let primary: Bool = false

    public init() {
        wrappedValue = nil
    }

    public init(wrappedValue: Value?, primary: Bool = false) {
        self.wrappedValue = wrappedValue
    }
}

