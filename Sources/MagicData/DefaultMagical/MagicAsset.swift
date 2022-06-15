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
            if #available(macOS 13.0, *) {
                let data = try Data(contentsOf: URL(filePath: value))
                if let value = Element.init(data) {
                    return .init(value: value)
                } else {
                    return nil
                }
            } else {
                let data = try Data(contentsOf: URL(fileURLWithPath: value))
                if let value = Element.init(data) {
                    return .init(value: value)
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }

    public func convert(magic: MagicData) async throws -> String {
        if value.filePathExtension.isEmpty {
            let path = magic.filePath.appendingPathExtension("\(UUID().uuidString)")
            if #available(macOS 13.0, *) {
                FileManager.default.createFile(atPath: path.path(), contents: try value.convert())
                return path.path()
            } else {
                FileManager.default.createFile(atPath: path.path, contents: try value.convert())
                return path.path
            }
        } else {
            let path = magic.filePath.appendingPathExtension("\(UUID().uuidString).\(value.filePathExtension)")
            if #available(macOS 13.0, *) {
                FileManager.default.createFile(atPath: path.path(), contents: try value.convert())
                return path.path()
            } else {
                FileManager.default.createFile(atPath: path.path, contents: try value.convert())
                return path.path
            }
        }
    }

    public static var type: MagicalType {
        return .string
    }

    public var value: Element
}
