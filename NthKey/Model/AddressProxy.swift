//
//  AddressProxy.swift
//  AddressProxy
//
//  Created by Sergey Vinogradov on 20.06.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation

struct AddressProxy {
    let address: String
    var used: Bool
}

extension AddressProxy: Identifiable, Equatable {
    var id: String { address }
}
