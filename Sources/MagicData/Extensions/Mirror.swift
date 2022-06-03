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
                return MagicExpress(name: child.label ?? "_error_", primary: primary, option: "\(mirror.subjectType)".hasPrefix("OptionMagicValue"), type: type, value: mirror.children.first(where: { (label: String?, value: Any) in
                    label == "wrappedValue"
                })?.value as? Magical)
            } else {
                return nil
            }
        }
    }
}
