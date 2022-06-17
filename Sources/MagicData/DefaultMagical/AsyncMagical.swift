//
//  AsyncMagical.swift
//  
//
//  Created by 朱浩宇 on 2022/6/17.
//

import Foundation

public struct AsyncMagical<Element: Magical>: Magical where Element: AsyncMagicalHostable {
    public static var type: MagicalType {
        return Element.type
    }

    private let host: Any?
    private let magic: MagicData?
    private var _value: Element?

    init(value: Element) {
        self.host = nil
        self._value = value
        self.magic = nil
    }

    private init(host: Any, magic: MagicData) {
        self.host = host
        self.magic = magic
        self._value = nil
    }

    public mutating func set(_ value: Element) {
        self._value = value
    }
}

extension AsyncMagical: MagicStringConvert where Element: MagicStringConvert {
    public static func create(_ value: String?, magic: MagicData) async throws -> AsyncMagical<Element>? {
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

    public func get() async throws -> Element {
        if let _value {
            return _value
        } else if let host = host as? String, let magic, let value = try await Element.create(host, magic: magic) {
            return value
        } else {
            throw MagicError.missValue
        }
    }
}

extension AsyncMagical: MagicDataConvert where Element: MagicDataConvert {
    public static func create(_ value: Data?, magic: MagicData) async throws -> AsyncMagical<Element>? {
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

    public func get() async throws -> Element {
        if let _value {
            return _value
        } else if let host = host as? Data, let magic, let value = try await Element.create(host, magic: magic) {
            return value
        } else {
            throw MagicError.missValue
        }
    }
}
