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
    
    init(_ receiveIndex: UInt, network: Network = .testnet) {
        if MultisigAddress.receivePublicHDkeys.isEmpty {
            let encodedCosigners = UserDefaults.standard.array(forKey: "cosigners")!
            precondition(!encodedCosigners.isEmpty)
            
            let fingerprint = UserDefaults.standard.data(forKey: "masterKeyFingerprint")!
            let entropyItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: fingerprint, accessGroup: nil)

            // TODO: handle error
            let entropy = try! entropyItem.readEntropy()
            let mnemonic = BIP39Mnemonic(entropy)!
            let seedHex = mnemonic.seedHex()
            let masterKey = HDKey(seedHex, network)!
            assert(masterKey.fingerprint == fingerprint)
        
            let encodedCosigner = encodedCosigners[0] as! Data
            let cosigner = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encodedCosigner)!
            
            let threshold = UserDefaults.standard.integer(forKey: "threshold")
            precondition(threshold > 0)

            let cointype: String
            switch (network) {
            case .mainnet:
                cointype = "0h"
            case .testnet:
                cointype = "1h"
            }
            
            MultisigAddress.receivePublicHDkeys.append(try! masterKey.derive(BIP32Path("m/48h/\(cointype)/0h/2h/0")!))
            MultisigAddress.receivePublicHDkeys.append(try! cosigner.hdKey.derive(BIP32Path("0")!))
        }
        precondition(!MultisigAddress.receivePublicHDkeys.isEmpty)
        

        let pubKeys = MultisigAddress.receivePublicHDkeys.map {key -> PubKey in
            let path = try! BIP32Path(Int(receiveIndex), relative: true)
            let childKey: HDKey = try! key.derive(path)
            return childKey.pubKey
        }

        let scriptPubKey = ScriptPubKey(multisig: pubKeys, threshold: 2)
        let receiveAddress = Address(scriptPubKey, network)!

        self.description = receiveAddress.description
        self.receiveIndex = receiveIndex
    }
    
    var id: UInt { receiveIndex }
    
}
