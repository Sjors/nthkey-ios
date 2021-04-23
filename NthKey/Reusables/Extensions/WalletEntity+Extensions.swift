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
        guard let value = WalletNetwork.valueFromInt16(self.network) else { return "" }
        return value.stringKey
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()

        id = UUID().uuidString
    }

    var wrappedNetwork: Network? {
        WalletNetwork.valueFromInt16(network)?.networkValue
    }

    var cosignersHDKeys: [HDKey] {
        var result: [HDKey] = []
        guard let items = cosigners?.allObjects as? [CosignerEntity] else { return result }
        for cosigner in items {
            guard let xpub = cosigner.xpub,
                  let master = cosigner.fingerprint,
                  let key = HDKey(xpub, masterKeyFingerprint: master) else { continue }
            result.append(key)
        }
        return result
    }
}
