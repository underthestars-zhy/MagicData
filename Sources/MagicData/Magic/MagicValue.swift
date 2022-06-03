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
    public var wrappedValue: Value {
        get {
            hostValue.value ?? .deafultPrimaryValue
        }

        set {
            hostValue.value = newValue
        }
    }
    internal let hostValue: MagicalValueHost<Value>
    internal let primary: Bool = true
    internal let type: MagicalType

    public init() {
        self.hostValue = .init(value: Value.deafultPrimaryValue)
        self.type = Value.type
    }

    public init(wrappedValue: Value) {
        self.hostValue = .init(value: wrappedValue)
        self.type = Value.type
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: _MagicValue {
    public var wrappedValue: Value {
        get {
            hostValue.value ?? .defualtValue
        }

        set {
            hostValue.value = newValue
        }
    }
    internal let hostValue: MagicalValueHost<Value>
    internal let primary: Bool = false
    internal let type: MagicalType

    public init() {
        self.hostValue = .init(value: Value.defualtValue)
        self.type = Value.type
    }

    public init(wrappedValue: Value) {
        self.hostValue = .init(value: wrappedValue)
        self.type = Value.type
    }
}

@propertyWrapper public struct OptionMagicValue<Value: Magical> {
    public var wrappedValue: Value? {
        get {
            hostValue.value
        }

        set {
            hostValue.value = newValue
        }
    }
    internal let hostValue: MagicalValueHost<Value>
    internal let primary: Bool = false
    internal let type: MagicalType

    public init() {
        hostValue = .init(value: nil)
        self.type = Value.type
    }

    public init(wrappedValue: Value?, primary: Bool = false) {
        self.hostValue = .init(value: wrappedValue)
        self.type = Value.type
    }
}

