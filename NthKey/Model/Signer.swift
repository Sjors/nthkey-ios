//
//  Signer.swift
//  Signer
//
//  Created by Sjors Provoost on 05/12/2019.
//  Copyright © 2019 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

public class Signer: NSObject, NSSecureCoding, Identifiable {
    public static var supportsSecureCoding = true
    
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
    
    required convenience public init(coder: NSCoder) {
        let fingerprint = coder.decodeObject(forKey: Keys.fingerprint) as! Data
        let derivation = coder.decodeObject(forKey: Keys.derivation) as! String // TODO: add raw initializer to BIP32Path
        let path = BIP32Path(derivation)!
        let xpub: String = coder.decodeObject(forKey: Keys.xpub) as! String // TODO: add raw initializer to HDKey
        let hdKey = HDKey(xpub, masterKeyFingerprint:fingerprint)!
        var name = coder.decodeObject(forKey: Keys.name) as? String
        if name == nil {
            name = ""
        }
        self.init(fingerprint: fingerprint, derivation: path, hdKey: hdKey, name: name!)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(fingerprint, forKey: Keys.fingerprint) // TODO: use constants for keys
        coder.encode(derivation.description, forKey: Keys.derivation)
        coder.encode(hdKey.description, forKey: Keys.xpub)
        coder.encode(name, forKey: Keys.name)
    }
    
    public static func getSigners(masterKey: HDKey? = nil) -> (Signer, [Signer]) {
        let encodedCosigners = UserDefaults.cosigners
        let fingerprint = UserDefaults.fingerprint! // FIXME: remove unwraping
        let network: Network = UserDefaults.mainnet ? .mainnet : .testnet
        
        // TODO: deduplicate from MultisigAddress.swift
        let seedHex = try! WalletManager.getMnemonic().seedHex()
        let masterKey = HDKey(seedHex, network)!
        assert(masterKey.fingerprint == fingerprint)
        
        let path = BIP32Path("m/48h/\(network == .mainnet ? "0h" : "1h")/0h/2h")!
        let ourKey = try! masterKey.derive(path)
        let us = Signer(fingerprint: fingerprint, derivation: path, hdKey: ourKey, name: "NthKey")

        guard !encodedCosigners.isEmpty else {
            return (us, [])
        }
        var cosigners: [Signer] = []
        for encodedCosigner in encodedCosigners {
            guard let cosigner: Signer = try? NSKeyedUnarchiver.unarchivedObject(ofClass: Signer.self, from: encodedCosigner ) else {
                print("Corrupted co-signers saved value")
                return (us, [])
            }
            cosigners.append(cosigner)
        }
        
        return (us, cosigners)
    }
    
    static func signPSBT(_ psbt: PSBT) -> PSBT {
        var psbtOut = psbt
        let (us, _) = Signer.getSigners()
        psbtOut.sign(us.hdKey)
        return psbtOut
    }
}

extension Signer {
    struct Keys {
        static let fingerprint = "fingerprint"
        static let derivation = "derivation"
        static let xpub = "xpub"
        static let name = "name"
    }
}
