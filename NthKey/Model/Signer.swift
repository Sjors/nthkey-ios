//
//  Signer.swift
//  Signer
//
//  Created by Sjors Provoost on 05/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

public class Signer: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true
    
    public let fingerprint: Data
    public let derivation: BIP32Path
    public let hdKey: HDKey // TODO: store derivation and fingerprint in HDKey?
    
    public init(fingerprint: Data, derivation: BIP32Path, hdKey: HDKey) {
        self.fingerprint = fingerprint
        self.derivation = derivation
        self.hdKey = hdKey
    }
    
    required convenience public init(coder: NSCoder) {
        let fingerprint = coder.decodeObject(forKey: "fingerprint") as! Data
        let derivation = coder.decodeObject(forKey: "derivation") as! String // TODO: add raw initializer to BIP32Path
        let path = BIP32Path(derivation)!
        let xpub: String = coder.decodeObject(forKey: "xpub") as! String // TODO: add raw initializer to HDKey
        let hdKey = HDKey(xpub, masterKeyFingerprint:fingerprint)!
        
        self.init(fingerprint: fingerprint, derivation: path, hdKey: hdKey)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(fingerprint, forKey:"fingerprint") // TODO: use constants for keys
        coder.encode(derivation.description, forKey:"derivation")
        coder.encode(hdKey.description, forKey:"xpub")
    }

    public static func getSigners() -> (Signer, [Signer]) {
        let encodedCosigners = UserDefaults.standard.array(forKey: "cosigners")
        
        let fingerprint = UserDefaults.standard.data(forKey: "masterKeyFingerprint")!
        let entropyItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: fingerprint, accessGroup: nil)

        // TODO: deduplicate from MultisigAddress.swift
        let entropy = try! entropyItem.readEntropy()
        let mnemonic = BIP39Mnemonic(entropy)!
        let seedHex = mnemonic.seedHex()
        let masterKey = HDKey(seedHex, .testnet)!
        assert(masterKey.fingerprint == fingerprint)

        let path = BIP32Path("m/48h/1h/0h/2h")!
        let ourKey = try! masterKey.derive(path)
        let us = Signer(fingerprint: fingerprint, derivation: path, hdKey: ourKey)

        guard encodedCosigners != nil && encodedCosigners!.count > 0 else {
            return (us, [])
        }
        let encodedCosigner = encodedCosigners![0] as! Data
        let cosigner = try! NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encodedCosigner)!
        
        return (us, [cosigner])
    }
    
    static func signPSBT(_ psbt: PSBT) -> PSBT {
        var psbtOut = psbt
        let (us, _) = Signer.getSigners()
        psbtOut.sign(us.hdKey)
        return psbtOut
    }
}
