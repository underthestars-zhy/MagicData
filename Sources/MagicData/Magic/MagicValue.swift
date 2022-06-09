//
//  MagicValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol Reversable {}

@propertyWrapper struct PrimaryMagicValue<Value: Magical>: Hashable where Value: MagicalPrimaryValue {
    public var wrappedValue: Value {
        get {
            (hostValue.value as! Value)
        }

        nonmutating set {
            hostValue.value = newValue
            hostValue.auto = false
        }
    }

    internal let hostValue: MagicalValueHost
    internal let primary: Bool = true
    internal let type: MagicalType
    internal let hashID = UUID()

    public init() {
        self.hostValue = .init(value: Value.deafultPrimaryValue, type: Value.self)
        self.type = Value.type
        self.hostValue.auto = true
    }

    public init(wrappedValue: Value) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }

    public func hash(into hasher: inout Hasher) {
        if let zIndex = hostValue.zIndex {
            hasher.combine("\(self.type)\(self.wrappedValue)\(self.primary)\(zIndex)")
        } else {
            hasher.combine("\(self.type)\(self.wrappedValue)\(self.primary)\(hashID)")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        let defualt = lhs.type == rhs.type && lhs.wrappedValue == rhs.wrappedValue

        if let lhsZIndex = lhs.hostValue.zIndex, let rhsZIndex = rhs.hostValue.zIndex {
            return defualt && lhsZIndex == rhsZIndex
        } else {
            return defualt && lhs.hashID == rhs.hashID
        }
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: Reversable, Hashable {
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
    internal let hashID = UUID()

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

    public func hash(into hasher: inout Hasher) {
        if let zIndex = hostValue.zIndex {
            hasher.combine("\(self.type)\(self.wrappedValue)\(self.primary)\(zIndex)")
        } else {
            hasher.combine("\(self.type)\(self.wrappedValue)\(self.primary)\(hashID)")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        let defualt = lhs.type == rhs.type && lhs.wrappedValue == rhs.wrappedValue

        if let lhsZIndex = lhs.hostValue.zIndex, let rhsZIndex = rhs.hostValue.zIndex {
            return defualt && lhsZIndex == rhsZIndex
        } else {
            return defualt && lhs.hashID == rhs.hashID
        }
    }
}

@propertyWrapper public struct OptionMagicValue<Value: Magical>: Reversable, Hashable {
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
    internal let hashID = UUID()

    public init() {
        hostValue = .init(value: nil, type: Value.self)
        self.type = Value.type
    }

    public init(wrappedValue: Value?) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }

    public func hash(into hasher: inout Hasher) {
        if let zIndex = hostValue.zIndex {
            if let wrappedValue {
                hasher.combine("\(self.type)\(wrappedValue)\(self.primary)\(zIndex)")
            } else {
                hasher.combine("\(self.type)\(self.primary)\(zIndex)")
            }
        } else {
            if let wrappedValue {
                hasher.combine("\(self.type)\(wrappedValue)\(self.primary)\(hashID)")
            } else {
                hasher.combine("\(self.type)\(self.primary)\(hashID)")
            }
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        let defualt = lhs.type == rhs.type && lhs.wrappedValue == rhs.wrappedValue

        if let lhsZIndex = lhs.hostValue.zIndex, let rhsZIndex = rhs.hostValue.zIndex {
            return defualt && lhsZIndex == rhsZIndex
        } else {
            return defualt && lhs.hashID == rhs.hashID
        }
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
