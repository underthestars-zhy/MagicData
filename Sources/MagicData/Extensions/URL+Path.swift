//
//  URL+Path.swift
//  
//
//  Created by 朱浩宇 on 2022/6/15.
//

import Foundation

extension URL {
    func universalPath() -> String {
        if #available(macOS 13.0, *) {
            return self.path()
        } else {
            return self.path
        }
    }

    func universalAppending(path: String) -> Self {
        if #available(macOS 13.0, *) {
            return self.appending(path: path)
        } else {
            return self.appendingPathComponent(path)
        }
    }
}
