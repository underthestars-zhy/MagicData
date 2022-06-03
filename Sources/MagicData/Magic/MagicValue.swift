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
    var type: MagicalType { get }
}

@propertyWrapper struct PrimaryMagicValue<Value: Magical>: _MagicValue where Value: MagicalPrimaryValue {
    public var wrappedValue: Value
    internal let primary: Bool = true
    internal let type: MagicalType

    public init() {
        self.wrappedValue = Value.deafultPrimaryValue
        self.type = Value.type
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.type = Value.type
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: _MagicValue {
    public var wrappedValue: Value
    internal let primary: Bool = false
    internal let type: MagicalType

    public init() {
        self.wrappedValue = Value.defualtValue
        self.type = Value.type
    }

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
        self.type = Value.type
    }
}

@propertyWrapper public struct OptionMagicValue<Value: Magical> {
    public var wrappedValue: Value?
    internal let primary: Bool = false
    internal let type: MagicalType

    public init() {
        wrappedValue = nil
        self.type = Value.type
    }

    public init(wrappedValue: Value?, primary: Bool = false) {
        self.wrappedValue = wrappedValue
        self.type = Value.type
    }
}

