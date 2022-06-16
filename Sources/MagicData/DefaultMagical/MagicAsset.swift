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
            return .init(value: Element.init(data))
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> String {
        if let pathExtension = value?.filePathExtension, !pathExtension.isEmpty {
            let path = magic.filePath.appendingPathExtension("\(UUID().uuidString).\(pathExtension)")
            FileManager.default.createFile(atPath: path.universalPath(), contents: try value?.convert())
            return path.universalPath()
        } else {
            let path = magic.filePath.appendingPathExtension("\(UUID().uuidString)")
            FileManager.default.createFile(atPath: path.universalPath(), contents: try value?.convert())
            return path.universalPath()
        }
    }

    public static var type: MagicalType {
        return .string
    }

    public var value: Element?
}
