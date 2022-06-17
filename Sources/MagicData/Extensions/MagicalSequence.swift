//
//  MagicalSequence.swift
//  
//
//  Created by 朱浩宇 on 2022/6/14.
//

import Foundation

protocol MagicalSequence {}

extension MagicalSet: MagicalSequence {}
extension Array: MagicalSequence where Element: MagicObject {}
extension AsyncMagical: MagicalSequence where Element: MagicalSequence {}
