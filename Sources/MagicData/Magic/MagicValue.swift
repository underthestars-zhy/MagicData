//
//  MagicValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol Reversable {}

@propertyWrapper struct PrimaryMagicValue<Value: Magical>: Equatable, Hashable where Value: MagicalPrimaryValue {
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

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type && lhs.wrappedValue == rhs.wrappedValue
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: Reversable, Equatable, Hashable {
    public var wrappedValue: Value {
        get {
            (hostValue.value as! Value)
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
        self.hostValue = .init(value: nil, type: Value.self)
        self.type = Value.type
    }

    public init(wrappedValue: Value) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type && lhs.wrappedValue == rhs.wrappedValue
    }
}

@propertyWrapper public struct OptionMagicValue<Value: Magical>: Reversable, Equatable, Hashable {
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

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type && lhs.wrappedValue == rhs.wrappedValue
    }
}

//@propertyWrapper public struct ReverseMagicValue<Value: Magical, Object: MagicObject> {
//    public var wrappedValue: Value? {
//        get {
//            hostValue.value as? Value
//        }
//
//        nonmutating set {
//            hostValue.value = newValue
//        }
//    }
//
//    internal let hostValue: MagicalValueHost
//    internal let primary: Bool = false
//    internal let type: MagicalType
//    internal let reverse: KeyPath<Object, Reversable>
//
//    public init(reverse: KeyPath<Object, Reversable>) {
//        hostValue = .init(value: nil, type: Value.self)
//        self.type = Value.type
//        self.reverse = reverse
//    }
//
//    public init(wrappedValue: Value?, reverse: KeyPath<Object, Reversable>) {
//        self.hostValue = .init(value: wrappedValue, type: Value.self)
//        self.type = Value.type
//        self.reverse = reverse
//    }
//}
//
