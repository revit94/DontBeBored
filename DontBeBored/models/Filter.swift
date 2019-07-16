//
//  Filter.swift
//  DontBeBored
//
//  Created by reztsov on 8/1/19.
//  Copyright © 2019 reztsov. All rights reserved.
//

import Foundation

enum Filter {
    case type(_ value: String)

    var value: String {
        switch self {
        case .type(let value): return value
        }
    }

    var rawValue: String {
        switch self {
        case .type: return "type"
        }
    }
}
