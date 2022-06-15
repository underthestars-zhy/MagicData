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
    var filePathExtension: String { get }
}

public extension MagicAssetConvert {
    var filePathExtension: String { "" }
}

extension String: MagicAssetConvert {
    public init?(_ data: Data) {
        self.init(data: data, encoding: .utf8)
    }

    public func convert() throws -> Data? {
        self.data(using: .utf8)
    }

    public var filePathExtension: String {
        "txt"
    }
}
