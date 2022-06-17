//
//  MagicAssetConvert.swift
//  
//
//  Created by 朱浩宇 on 2022/6/14.
//

import Foundation

public protocol MagicAssetConvert {
    init?(_ data: Data)
    func convert() throws -> Data?
}

extension String: MagicAssetConvert {
    public init?(_ data: Data) {
        self.init(data: data, encoding: .utf8)
    }

    public func convert() throws -> Data? {
        self.data(using: .utf8)
    }
}

extension Data: MagicAssetConvert {
    public func convert() throws -> Data? {
        self
    }
}

extension MagicalCodable {
    public init?(_ data: Data) {
        if let decode = (try? JSONDecoder().decode(Self.self, from: data)) {
            self = decode
        } else {
            return nil
        }
    }

    public func convert() throws -> Data? {
        try? JSONEncoder().encode(self)
    }
}

extension Array: MagicAssetConvert where Element: Codable {
    public init?(_ data: Data) {
        if let decode = (try? JSONDecoder().decode(Self.self, from: data)) {
            self = decode
        } else {
            return nil
        }
    }

    public func convert() throws -> Data? {
        try? JSONEncoder().encode(self)
    }
}

extension Set: MagicAssetConvert where Element: Codable {
    public init?(_ data: Data) {
        if let decode = (try? JSONDecoder().decode(Self.self, from: data)) {
            self = decode
        } else {
            return nil
        }
    }

    public func convert() throws -> Data? {
        try? JSONEncoder().encode(self)
    }
}

extension Dictionary: MagicAssetConvert where Key: Codable, Value: Codable {
    public init?(_ data: Data) {
        if let decode = (try? JSONDecoder().decode(Self.self, from: data)) {
            self = decode
        } else {
            return nil
        }
    }

    public func convert() throws -> Data? {
        try? JSONEncoder().encode(self)
    }
}
