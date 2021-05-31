//
//  Signer.swift
//  Signer
//
//  Created by Sjors Provoost on 05/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

public class Signer: NSObject, Identifiable {
    
    public let fingerprint: Data
    public let derivation: BIP32Path
    public let hdKey: HDKey // TODO: store derivation and fingerprint in HDKey?
    public let name: String
    
    public init(fingerprint: Data, derivation: BIP32Path, hdKey: HDKey, name: String) {
        self.fingerprint = fingerprint
        self.name = name
        self.derivation = derivation
        self.hdKey = hdKey
    }
    
    public static func getSignerUs(_ network: Network) -> Signer {
        let fingerprint = UserDefaults.fingerprint!

        let seedHex = try! SeedManager.getMnemonic().seedHex()
        let masterKey = HDKey(seedHex, network)!
        assert(masterKey.fingerprint == fingerprint)
        
        let path = BIP32Path("m/48h/\(network == .mainnet ? "0h" : "1h")/0h/2h")!
        let ourKey = try! masterKey.derive(path)

        return Signer(fingerprint: fingerprint, derivation: path, hdKey: ourKey, name: "NthKey")
    }
    
    static func signPSBT(_ psbt: PSBT) -> PSBT {
        var psbtOut = psbt
        let us = Signer.getSignerUs(psbt.network)
        psbtOut.sign(us.hdKey)
        return psbtOut
    }
}
