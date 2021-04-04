//
//  WalletEntity+Extensions.swift
//  WalletEntity+Extensions
//
//  Created by Sergey Vinogradov on 29.03.2021.
//  Copyright © 2021 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

extension WalletEntity {
    var networkKey: String {
        guard let value = Network.valueFromInt16(self.network) else { return "" }
        return value.stringKey
    }
}
