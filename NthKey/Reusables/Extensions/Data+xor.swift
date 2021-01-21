//
//  Data+xor.swift
//  NthKey
//
//  Created by Sjors Provoost on 01/12/2020.
//  Copyright © 2020 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

public extension Data {
    func xor(_ key: Data) -> Data {
        var result = self
        for i in 0..<self.count {
            result[i] ^= key[i % key.count]
        }
        return result
    }
}
