//
//  Codable.swift
//  
//
//  Created by 朱浩宇 on 2022/6/4.
//

import Foundation

public protocol MagicalCodable: Magical, MagicDataConvert where Self: Codable {

}

public extension MagicalCodable {
    static func create(_ value: Data?) -> Self? {
        if let value = value {
            return try? JSONDecoder().decode(Self.self, from: value)
        } else {
            return nil
        }
    }
    
    static var type: MagicalType {
        return .data
    }

    func convert() -> Data {
        return (try? JSONEncoder().encode(self)) ?? Data()
    }
}