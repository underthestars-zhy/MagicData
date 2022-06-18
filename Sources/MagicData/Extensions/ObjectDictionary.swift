//
//  ObjectDictionary.swift
//  
//
//  Created by 朱浩宇 on 2022/6/18.
//

import Foundation

protocol ObjectDictionary {
    static func getAllID(_ data: Data) throws -> [Int]
}

extension Dictionary: ObjectDictionary where Value: MagicObject, Key: Codable {
    static func getAllID(_ data: Data) throws -> [Int] {
        let list = try JSONDecoder().decode([Key: Int].self, from: data)
        return list.map(\.value)
    }
}
