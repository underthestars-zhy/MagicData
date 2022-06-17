//
//  MagicAsset.swift
//  
//
//  Created by 朱浩宇 on 2022/6/14.
//

import Foundation

public struct MagicAsset<Element>: Magical, MagicStringConvert where Element: MagicAssetConvert {
    public static func create(_ value: String?, magic: MagicData) async throws -> MagicAsset<Element>? {
        if let value {
            let data = try Data(contentsOf: URL(universalFilePath: value))
            let asset = Self.init(value: Element.init(data))
            asset.host.path = URL(universalFilePath: value)

            return asset
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> String {
        if let path {
            try value?.convert()?.write(to: path)
            return path.universalPath()
        } else {
            if let pathExtension, !pathExtension.isEmpty {
                let path = magic.filePath.universalAppending(path: "\(UUID().uuidString).\(pathExtension)")
                FileManager.default.createFile(atPath: path.universalPath(), contents: try value?.convert())
                host.path = path
                return path.universalPath()
            } else {
                let path = magic.filePath.universalAppending(path: "\(UUID().uuidString)")
                FileManager.default.createFile(atPath: path.universalPath(), contents: try value?.convert())
                host.path = path
                return path.universalPath()
            }
        }
    }

    public static var type: MagicalType {
        return .string
    }

    public var value: Element?
    public let pathExtension: String?
    private let host = Host()

    public var path: URL? {
        host.path
    }

    public init(value: Element? = nil, pathExtension: String? = nil) {
        self.value = value
        self.pathExtension = pathExtension
    }
}

fileprivate class Host {
    var path: URL?
}
