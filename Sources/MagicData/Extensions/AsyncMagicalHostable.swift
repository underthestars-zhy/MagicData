//
//  AsyncMagicalHostable.swift
//  
//
//  Created by 朱浩宇 on 2022/6/17.
//

import Foundation

public protocol AsyncMagicalHostable {}

extension MagicAsset: AsyncMagicalHostable {}
extension Array: AsyncMagicalHostable where Element: MagicObject {}
extension MagicalSet: MagicObject {}
