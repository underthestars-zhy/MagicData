//
//  File.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

extension Mirror {
    func createExpresses() -> [MagicExpress] {
        self.children.compactMap { child in
            let mirror = Mirror(reflecting: child.value)
            if (
                "\(mirror.subjectType)".hasPrefix("PrimaryMagicValue") ||
                "\(mirror.subjectType)".hasPrefix("MagicValue") ||
                "\(mirror.subjectType)".hasPrefix("OptionMagicValue")
            ),
               let primary = mirror.children.first(where: { (label: String?, value: Any) in
                   label == "primary"
               })?.value as? Bool,
               let type = mirror.children.first(where: { (label: String?, value: Any) in
                   label == "type"
               })?.value as? MagicalType {
                return MagicExpress(name: child.label ?? "_error_", primary: primary, option: "\(mirror.subjectType)".hasPrefix("OptionMagicValue"), type: type, value: getValueFromHost(mirror: mirror), auto:  mirror.getHost()?.auto ?? false, zIndex: mirror.getHost()?.zIndex ?? 0)
            } else {
                return nil
            }
        }
    }

    func getValueFromHost(mirror: Mirror) -> (any Magical)? {
        guard let value = mirror.children.first(where: { (label: String?, value: Any) in
            label == "hostValue"
        })?.value else { return nil }

        let _mirror = Mirror(reflecting: value)

        return (_mirror.children.first { lable, value in
            lable == "value"
        }?.value as? (any Magical)?)?.flatMap { $0 }
    }

    func getHost() -> MagicalValueHost? {
        return self.children.first(where: { (label: String?, value: Any) in
            label == "hostValue"
        })?.value as? MagicalValueHost
    }

    func getValue(by express: MagicExpress) -> (any Magical)? {
        guard let magicValue = self.children.first(where: { (label: String?, value: Any) in
            label == express.name
        })?.value else { return nil }

        let mirror = Mirror(reflecting: magicValue)

        return getValueFromHost(mirror: mirror)
    }

    func getAllHost() -> [MagicalValueHost] {
        return self.children.compactMap { child in
            let mirror = Mirror(reflecting: child.value)

            return mirror.getHost()
        }
    }

    func getAllHostDictionary() -> [String : MagicalValueHost] {
        var res = [String : MagicalValueHost]()
        self.children.forEach { child in
            let mirror = Mirror(reflecting: child.value)

            if let label = child.label {
                res[label] = mirror.getHost()
            }
        }

        return res
    }

    func getAllReverse() -> [_ReverseMagicValue] {
        return self.children.compactMap { (label: String?, value: Any) in
            value as? _ReverseMagicValue
        }
    }

    func getType() -> (any MagicObject.Type)? {
        return self.children.first { (label: String?, value: Any) in
            label == "type"
        }?.value as? (any MagicObject.Type)
    }

    func getIDHost() -> MagicalIDHost? {
        return self.children.first { (label: String?, value: Any) in
            label == "hostValue"
        }?.value as? MagicalIDHost
    }

    func getPrimaryValue() -> (any MagicalPrimaryValue)? {
        guard let primary = self.children.first(where: { child in
            let mirror = Mirror(reflecting: child.value)
            return "\(mirror.subjectType)".hasPrefix("PrimaryMagicValue")
        })?.value else { return nil }

        let mirror = Mirror(reflecting: primary)

        return (mirror.children.first { (label: String?, value: Any) in
            label == "hostValue"
        }?.value as? MagicalValueHost)?.value.flatMap({ value in
            value as? (any MagicalPrimaryValue)
        })
    }
}
