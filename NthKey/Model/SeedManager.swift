//
//  SeedManager.swift
//  SeedManager
//
//  Created by Sjors Provoost on 10/01/2020.
//  Copyright © 2020 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally
import OutputDescriptors

struct SeedManager {
    var hasSeed: Bool
    
    enum WalletManagerError: Error {
        case noEntropyMask
    }

    init() {
        hasSeed = UserDefaults.fingerprints != nil
    }

    static func getMnemonic() throws -> BIP39Mnemonic  {
        let data = try KeychainEntropyItem.read(service: "NthKeyService", accessGroup: nil)
        guard let mask = UserDefaults.entropyMask else {
            throw WalletManagerError.noEntropyMask
        }

        let entropy = BIP39Entropy(data.xor(mask))
        return BIP39Mnemonic(entropy)!
    }
    
    mutating func setEntropy(_ entropy: BIP39Entropy) {
        // Delete existing entry, if any:
        try! KeychainEntropyItem.delete(service: "NthKeyService", accessGroup: nil)
        
        // Generate additional entropy, stored in NSUserDefaults, to XOR the keychain entry.
        // The keychain is not wiped when you uninstall the app, but NSUserDefaults is, so
        // this ensures the BIP39 entropy is really gone when the user removes the app.
        var maskBytes = [Int8](repeating: 0, count: entropy.data.count)
        let status = SecRandomCopyBytes(kSecRandomDefault, maskBytes.count, &maskBytes)
        let mask = Data(bytes: maskBytes, count: maskBytes.count)
        let maskedEntropy = entropy.data.xor(mask)
        precondition(status == errSecSuccess)
        do {
            try KeychainEntropyItem.save(entropy: maskedEntropy, service: "NthKeyService", accessGroup: nil)
        } catch NthKey.KeychainEntropyItem.KeychainError.entropyAlreadyExists {
            print("Keychain entropy entry was not properly wiped earlier in this function")
            precondition(false)
        } catch {
            print("Unknown unhandled error saving to keychain")
            precondition(false)
        }
        let seedHex = BIP39Mnemonic(entropy)!.seedHex()

        var fingerprints: [String: Data] = [:]
        for network in Network.allCases {
            let masterKey = HDKey(seedHex, network)!
            fingerprints[network.stringKey] = masterKey.fingerprint
        }
        UserDefaults.fingerprints = fingerprints
        UserDefaults.entropyMask = mask

        self.hasSeed = true
    }
    
    mutating func generateSeed() {
        var bytes = [Int8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            let entropy = BIP39Entropy(Data(bytes: bytes, count: bytes.count))
            setEntropy(entropy)
        }
    }
    
    func ourPubKey(network: Network)  -> Data {
        guard let fingerprints = UserDefaults.fingerprints,
              let fingerprint = fingerprints[network.stringKey] else {
            return Data.init()
        }
        // TODO: handle error
        let seedHex = try! SeedManager.getMnemonic().seedHex()
        let masterKey = HDKey(seedHex, network)!
        assert(masterKey.fingerprint == fingerprint)

        let path = BIP32Path("m/48h/\(network == .mainnet ? "0h" : "1h")/0h/2h")!
        let account = try! masterKey.derive(path)

        // Specter compatible JSON format:
        struct SpecterExport : Codable {
            var MasterFingerprint: String
            var AccountKeyPath: String
            var ExtPubKey: String
        }
        let xpub = Data(base58: account.xpub)!
        let export = SpecterExport(MasterFingerprint: fingerprint.hexString.uppercased(), AccountKeyPath: "48h/\(network == .mainnet ? "0h" : "1h")/0h/2h", ExtPubKey: xpub.base58)

        let encoder = JSONEncoder()
        return try! encoder.encode(export)
    }

    func mnemonic() -> String {
        if UserDefaults.entropyMask != nil {
            return try! SeedManager.getMnemonic().description
        } else {
            return ""
        }
    }
}
