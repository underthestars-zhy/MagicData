//
//  LazyValueContain.swift
//  
//
//  Created by 朱浩宇 on 2022/7/10.
//

import Foundation

protocol LazyValueContain {}

extension Array: LazyValueContain where Element: MagicObject {}
extension Dictionary: LazyValueContain where Value: MagicObject {}
extension MagicalSet: LazyValueContain {}
