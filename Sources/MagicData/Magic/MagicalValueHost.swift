//
//  MagicalValueHost.swift
//  
//
//  Created by 朱浩宇 on 2022/6/3.
//

import Foundation

class MagicalValueHost<Value> where Value: Magical {
    var value: Value?

    init(value: Value?) {
        self.value = value
    }
}
