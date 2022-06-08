//
//  MagicalValueHost.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

class MagicalValueHost: NSObject {
    var value: Any?
    let type: any Magical.Type
    var auto = false
    var zIndex: Int?

    func set(value _value: Any?) {
        value = _value
    }

    init(value: Any?, type: any Magical.Type) {
        self.value = value
        self.type = type
    }
    
}

