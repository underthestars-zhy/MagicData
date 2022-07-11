//
//  AsyncMagical.swift
//  
//
//  Created by 朱浩宇 on 2022/6/17.
//

import Foundation

public struct AsyncMagical<AsyncElement: Magical>: Magical where AsyncElement: AsyncMagicalHostable {
    public static var type: MagicalType {
        return AsyncElement.type
    }

    private let host: Any?
    private let magic: MagicData?
    private var _value: AsyncElement?

    public init(value: AsyncElement) {
        self.host = nil
        self._value = value
        self.magic = nil
    }

    private init(host: Any, magic: MagicData) {
        self.host = host
        self.magic = magic
        self._value = nil
    }

    public mutating func set(_ value: AsyncElement) {
        self._value = value
    }
}

extension AsyncMagical: MagicStringConvert where AsyncElement: MagicStringConvert {
    public static func create(_ value: String?, magic: MagicData) async throws -> AsyncMagical<AsyncElement>? {
        if let value {
            return self.init(host: value, magic: magic)
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> String {
        if let _value {
            return try await _value.convert(magic: magic)
        } else if let host = host as? String {
            return host
        } else {
            throw MagicError.missValue
        }
    }

    public mutating func get() async throws -> AsyncElement {
        if let _value {
            return _value
        } else if let host = host as? String, let magic, let value = try await AsyncElement.create(host, magic: magic) {
            self._value = value
            return value
        } else {
            throw MagicError.missValue
        }
    }
}

extension AsyncMagical: MagicDataConvert where AsyncElement: MagicDataConvert {
    public static func create(_ value: Data?, magic: MagicData) async throws -> AsyncMagical<AsyncElement>? {
        if let value {
            return self.init(host: value, magic: magic)
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> Data {
        if let _value {
            return try await _value.convert(magic: magic)
        } else if let host = host as? Data {
            return host
        } else {
            throw MagicError.missValue
        }
    }

    public func get() async throws -> AsyncElement {
        if let _value {
            return _value
        } else if let host = host as? Data, let magic, let value = try await AsyncElement.create(host, magic: magic) {
            return value
        } else {
            throw MagicError.missValue
        }
    }
}

extension AsyncMagical: MagicIntConvert where AsyncElement: MagicIntConvert {
    public static func create(_ value: Int?, magic: MagicData) async throws -> AsyncMagical<AsyncElement>? {
        if let value {
            return self.init(host: value, magic: magic)
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> Int {
        if let _value {
            return try await _value.convert(magic: magic)
        } else if let host = host as? Int {
            return host
        } else {
            throw MagicError.missValue
        }
    }

    public func get() async throws -> AsyncElement {
        if let _value {
            return _value
        } else if let host = host as? Int, let magic, let value = try await AsyncElement.create(host, magic: magic) {
            return value
        } else {
            throw MagicError.missValue
        }
    }
}

extension AsyncMagical: MagicDoubleConvert where AsyncElement: MagicDoubleConvert {
    public static func create(_ value: Double?, magic: MagicData) async throws -> AsyncMagical<AsyncElement>? {
        if let value {
            return self.init(host: value, magic: magic)
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> Double {
        if let _value {
            return try await _value.convert(magic: magic)
        } else if let host = host as? Double {
            return host
        } else {
            throw MagicError.missValue
        }
    }

    public func get() async throws -> AsyncElement {
        if let _value {
            return _value
        } else if let host = host as? Double, let magic, let value = try await AsyncElement.create(host, magic: magic) {
            return value
        } else {
            throw MagicError.missValue
        }
    }
}

extension AsyncMagical where AsyncElement: Collection & AsyncSequenceCreatable & MagicDataConvert {
    public func createAsyncStream() throws -> AsyncThrowingStream<AsyncElement.Element, Error> {
        if let host, let magic {
            let values = try AsyncElement.create(host)
            let Object = AsyncElement.getObject()
            return AsyncThrowingStream { continuation in
                Task {
                    do {
                        for value in values {
                            if value.0 == nil {
                                // Array or Set
                                if let object = try await AsyncElement.createObject(value.1, magic: magic, object: Object), let typeObject = object as? AsyncElement.Element {
                                    continuation.yield(typeObject)
                                }
                            } else if let key = value.0 {
                                // Dictionary
                                if let object = try await AsyncElement.createObject(value.1, magic: magic, object: Object), let typeObject = (key: key, value: object) as? AsyncElement.Element {
                                    continuation.yield(typeObject)
                                }
                            }
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        } else if let _value {
            return AsyncThrowingStream { continuation in
                for item in _value {
                    continuation.yield(item)
                }
                continuation.finish()
            }
        } else {
            throw MagicError.missValue
        }
    }

    public func randomValue() async throws -> AsyncElement.Element? {
        if let host, let magic {
            let values = try AsyncElement.create(host)
            if let value = values.randomElement() {
                let Object = AsyncElement.getObject()
                if value.0 == nil {
                    // Array or Set
                    if let object = try await AsyncElement.createObject(value.1, magic: magic, object: Object), let typeObject = object as? AsyncElement.Element {
                        return typeObject
                    } else {
                        return nil
                    }
                } else if let key = value.0 {
                    // Dictionary
                    if let object = try await AsyncElement.createObject(value.1, magic: magic, object: Object), let typeObject = (key: key, value: object) as? AsyncElement.Element {
                        return typeObject
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else if let _value {
            return _value.randomElement()
        } else {
            throw MagicError.missValue
        }
    }

    public var count: Int {
        get throws {
            if let host {
                let values = try AsyncElement.create(host)
                return values.count
            } else if let _value {
                return _value.count
            } else {
                throw MagicError.missValue
            }
        }
    }
}
