//
//  MagicalValueHost.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

class MagicalValueHost<Value>: NSObject where Value: Magical {
    var value: Value?

    func set(value _value: Any?) {
        
    }

    init(value: Value?) {
        self.value = value
    }
}
