//
//  MagicValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol Reversable {}

@propertyWrapper struct PrimaryMagicValue<Value: Magical> where Value: MagicalPrimaryValue {
    public var wrappedValue: Value {
        get {
            (hostValue.value as? Value) ?? .deafultPrimaryValue
        }

        nonmutating set {
            hostValue.value = newValue
            hostValue.auto = false
        }
    }

    internal let hostValue: MagicalValueHost
    internal let primary: Bool = true
    internal let type: MagicalType

    public init() {
        self.hostValue = .init(value: Value.deafultPrimaryValue, type: Value.self)
        self.type = Value.type
        self.hostValue.auto = true
    }

    public init(wrappedValue: Value) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: Reversable {
    public var wrappedValue: Value {
        get {
            (hostValue.value as? Value) ?? .defualtValue!
        }

        nonmutating set {
            hostValue.value = newValue
        }
    }

    internal let hostValue: MagicalValueHost
    internal let primary: Bool = false
    internal let type: MagicalType

    public var projectedValue: Reversable {
        get {
            self
        }
    }

    public init() {
        self.hostValue = .init(value: Value.defualtValue, type: Value.self)
        self.type = Value.type
    }

    public init(wrappedValue: Value) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }
}

@propertyWrapper public struct OptionMagicValue<Value: Magical>: Reversable {
    public var wrappedValue: Value? {
        get {
            hostValue.value as? Value
        }

        nonmutating set {
            hostValue.value = newValue
        }
    }

    public var projectedValue: Reversable {
        get {
            self
        }
    }

    internal let hostValue: MagicalValueHost
    internal let primary: Bool = false
    internal let type: MagicalType

    public init() {
        hostValue = .init(value: nil, type: Value.self)
        self.type = Value.type
    }

    public init(wrappedValue: Value?) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }
}

@propertyWrapper public struct ReverseMagicValue<Value: Magical> {
    public var wrappedValue: Value? {
        get {
            hostValue.value as? Value
        }

        nonmutating set {
            hostValue.value = newValue
        }
    }
    internal let hostValue: MagicalValueHost
    internal let primary: Bool = false
    internal let type: MagicalType
    internal let reverse: KeyPath<Value, Reversable>

    public init(reverse: KeyPath<Value, Reversable>) {
        hostValue = .init(value: nil, type: Value.self)
        self.type = Value.type
        self.reverse = reverse
    }

    public init(wrappedValue: Value?, reverse: KeyPath<Value, Reversable>) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
        self.reverse = reverse
    }
}

