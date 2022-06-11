//
//  MagicalIDHost.swift
//  
//
//  Created by 朱浩宇 on 2022/6/11.
//

import Foundation

class MagicalIDHost {
    var value: [Int] = []
    var magic: MagicData?
    var zIndex: Int?

    func setValue(_ ids: [Int], magic: MagicData) {
        self.value = ids
        self.magic = magic
    }
}
