//
//  MagicValue.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

@propertyWrapper public struct PrimaryMagicValue<Value: Magical> where Value: MagicalPrimaryValue {
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
}

@propertyWrapper public struct MagicValue<Value: Magical>: Reversable {
    public func allID(_ data: Data) throws -> [Int] {
        if let Sequence = Value.self as? MagicalSequence.Type {
            return try Sequence.allID(data)
        } else {
            return []
        }
    }

    public func isSequence() -> Bool {
        return Value.self is MagicalSequence.Type
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
}

@propertyWrapper public struct OptionMagicValue<Value: Magical>: Reversable {
    public func allID(_ data: Data) throws -> [Int] {
        if let Sequence = Value.self as? MagicalSequence.Type {
            return try Sequence.allID(data)
        } else {
            return []
        }
    }
    
    public func isSequence() -> Bool {
        return Value.self is MagicalSequence.Type
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

    public init() {
        hostValue = .init(value: nil, type: Value.self)
        self.type = Value.type
    }

    public init(wrappedValue: Value?) {
        self.hostValue = .init(value: wrappedValue, type: Value.self)
        self.type = Value.type
    }
}

public protocol _ReverseMagicValue {
    func createProjectValue(_ object: any MagicObject) -> Reversable?
}

@propertyWrapper public struct ReverseMagicValue<Object: MagicObject, Value: _AsyncMagicalSet>: _ReverseMagicValue {
    public var wrappedValue: Value {
        if let magic = hostValue.magic {
            return Value.init(hostValue.value, magic: magic)
        }

        return Value.init()
    }

    internal let reverse: KeyPath<Object, Reversable>
    internal let hostValue = MagicalIDHost()
    internal let type: any MagicObject.Type

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
}

