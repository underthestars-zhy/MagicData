//
//  MagicValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

public protocol Reversable {
    func isSet() -> Bool
    var reversableID: UUID { get }
}

@propertyWrapper public struct PrimaryMagicValue<Value: Magical>: Hashable where Value: MagicalPrimaryValue {
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
            hasher.combine("\(self.type)\(self.wrappedValue)\(self.primary)\(wrappedValue)")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

@propertyWrapper public struct MagicValue<Value: Magical>: Reversable, Hashable {
    public func isSet() -> Bool {
        return "\(Value.self)".hasPrefix("MagicalSet")
    }

    public var reversableID: UUID = .init()

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
    public func isSet() -> Bool {
        return "\(Value.self)".hasPrefix("MagicalSet")
    }

    public var reversableID: UUID = .init()
    
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

public protocol _ReverseMagicValue {
    func createProjectValue(_ object: any MagicObject) -> Reversable?
}

@propertyWrapper public struct ReverseMagicValue<Object: MagicObject, Value: _AsyncMagicalSet>: _ReverseMagicValue, Hashable {
    public var wrappedValue: Value {
        if let magic = hostValue.magic {
            return Value.init(hostValue.value, magic: magic)
        }

        return Value.init()
    }

    internal let reverse: KeyPath<Object, Reversable>
    internal let hostValue = MagicalIDHost()
    internal let type: any MagicObject.Type
    internal let hashID = UUID()


    public init(_ reverse: KeyPath<Object, Reversable>) {
        self.reverse = reverse
        self.type = Object.self
    }

    public func createProjectValue(_ object: any MagicObject) -> Reversable? {
        if let object = object as? Object {
            return object[keyPath: reverse]
        }

        return nil
    }

    public func hash(into hasher: inout Hasher) {
        if let zIndex = hostValue.zIndex {
            hasher.combine("\(reverse)\(type)\(zIndex)")
        } else {
            hasher.combine("\(reverse)\(type)\(hashID)")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

