//
//   Nth KeyAddress.swift
//   Nth KeyAddress
//
//  Created by Sjors Provoost on 12/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

struct MultisigAddress : Identifiable {
    let receiveIndex: UInt
    let description: String
    
    static var receivePublicHDkeys: [HDKey] = []
    
    init(threshold: UInt, receiveIndex: UInt, network: Network = .testnet) {
        if MultisigAddress.receivePublicHDkeys.isEmpty {
            let (us, cosigners) = Signer.getSigners()

            MultisigAddress.receivePublicHDkeys.append(try! us.hdKey.derive(BIP32Path("0")!))
            for cosigner in cosigners {
                MultisigAddress.receivePublicHDkeys.append(try! cosigner.hdKey.derive(BIP32Path("0")!))
            }
        }
        precondition(!MultisigAddress.receivePublicHDkeys.isEmpty)
        

        let pubKeys = MultisigAddress.receivePublicHDkeys.map {key -> PubKey in
            let path = try! BIP32Path(Int(receiveIndex), relative: true)
            let childKey: HDKey = try! key.derive(path)
            return childKey.pubKey
        }

        let scriptPubKey = ScriptPubKey(multisig: pubKeys, threshold: threshold)
        let receiveAddress = Address(scriptPubKey, network)!

        self.description = receiveAddress.description
        self.receiveIndex = receiveIndex
    }
    
    var id: UInt { receiveIndex }
    
}
