//
//  WalletManager.swift
//  WalletManager
//
//  Created by Sjors Provoost on 10/01/2020.
//  Copyright © 2020 Purple Dunes. Distributed under the MIT software
//  license, see the accompanying file LICENSE.md

import Foundation
import LibWally

struct WalletManager {
    var us: Signer
    var cosigners: [Signer]
    var threshold: Int = 0
    var hasWallet: Bool = false

    init() {
        (us, cosigners) = Signer.getSigners()
        threshold = UserDefaults.standard.integer(forKey:"threshold")
        hasWallet = UserDefaults.standard.bool(forKey:"hasWallet")
    }

    var hasCosigners: Bool {
        return cosigners.count > 0
    }

    static func initialize() {
        var masterKey: HDKey
        let defaults = UserDefaults.standard

        if let fingerprint = defaults.data(forKey: "masterKeyFingerprint") {
            let mnemonic = getMnemonic(fingerprint);
            let seedHex = mnemonic.seedHex()
            masterKey = HDKey(seedHex, .testnet)!
            assert(masterKey.fingerprint == fingerprint)
        } else {
            var bytes = [Int8](repeating: 0, count: 32)
            let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            let entropy = BIP39Entropy(Data(bytes: bytes, count: bytes.count))
            let seedHex = BIP39Mnemonic(entropy)!.seedHex()
            masterKey = HDKey(seedHex, .testnet)!

            if status == errSecSuccess { // Always test the status.
                let seedItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: masterKey.fingerprint, accessGroup: nil)
                // TODO: handle error
                try! seedItem.saveEntropy(entropy)
                defaults.set(masterKey.fingerprint, forKey: "masterKeyFingerprint")
            }

        }
    }

    static func getMnemonic(_ fingerprint: Data) -> BIP39Mnemonic {
        let entropyItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: fingerprint, accessGroup: nil)

        // Uncomment to reset
//             defaults.removeObject(forKey: "masterKeyFingerprint")
//             try! entropyItem.deleteItem()
//             return false

        // TODO: handle error
        let entropy = try! entropyItem.readEntropy()
        return BIP39Mnemonic(entropy)!
    }
    
    func ourPubKey()  -> Data {
        let fingerprint = UserDefaults.standard.data(forKey: "masterKeyFingerprint")!
        let entropyItem = KeychainEntropyItem(service: "NthKeyService", fingerprint: fingerprint, accessGroup: nil)

        // TODO: handle error
        let entropy = try! entropyItem.readEntropy()
        let mnemonic = BIP39Mnemonic(entropy)!
        let seedHex = mnemonic.seedHex()
        let masterKey = HDKey(seedHex, .testnet)!
        assert(masterKey.fingerprint == fingerprint)

        let path = BIP32Path("m/48h/1h/0h/2h")!
        let account = try! masterKey.derive(path)

        // Specter compatible JSON format:
        struct SpecterExport : Codable {
            var MasterFingerprint: String
            var AccountKeyPath: String
            var ExtPubKey: String
        }
        let xpub = Data(base58: account.xpub)!
        let export = SpecterExport(MasterFingerprint: fingerprint.hexString.uppercased(), AccountKeyPath: "48h/1h/0h/2h", ExtPubKey: xpub.base58)

        let encoder = JSONEncoder()
        return try! encoder.encode(export)
    }

    mutating func wipeWallet() {
        UserDefaults.standard.removeObject(forKey: "cosigners")
        self.cosigners = []
        UserDefaults.standard.removeObject(forKey: "hasWallet")
        self.hasWallet = false
    }

    mutating func loadWalletFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)

            // Check if it uses Specter format:
            if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
               let descriptor = jsonResult["descriptor"] as? String
            {
                print(descriptor)
                // TODO:
                // * check that it matches $wsh(sortedmulti(:n,.*))#checksum, take n, the middel stuff, checksum
                // * split middle stuff at comma, for each
                //   * check matches [048117aa/48h/1h/0h/2h]tpubDF , take fingerprint, path, xpub
                //   * add cosigner
                // * set threshold
                // * create wallet
                
//                let extendedKey = Data(base58: p2wsh)!
//                let expectedMarkers: Set<Data> = [
//                    Data("043587cf")!, // tpub (testnet)
//                    Data("02575483")! // Vpub (testnet, p2wsh, public)
//                ]
//                let marker = Data(extendedKey.subdata(in: 0..<4))
//                if !expectedMarkers.contains(marker) {
//                    NSLog("Expected tpub or Vpub marker (0x043587cf or 0x02575483), got 0x%@", marker.hexString)
//                    return
//                }
//                // Convert marker to tpub for internal use:
//                let p2wsh_tpub = Data("043587cf")! + extendedKey.subdata(in: 4..<extendedKey.count)
//                let cosigner = Signer(fingerprint: Data(xfp)!, derivation: BIP32Path(p2wsh_deriv)!, hdKey: HDKey(p2wsh_tpub.base58)!, name: "")
//                self.cosigners.append(cosigner)
//                self.saveCosigners()
                
                // Wallet creation:
//                let defaults = UserDefaults.standard
//                defaults.set(threshold, forKey: "threshold")
//                defaults.set(true, forKey: "hasWallet")
//                self.hasWallet = true
            } else {
                print("JSON format not recognized:")
                print(jsonResult)
            }
        } catch {
            NSLog("Something went wrong parsing JSON file")
            return
        }
    }

    mutating func saveCosigners() {
        var encodedCosigners: [Data] = []
        for cosigner in self.cosigners {
            let encoded = try! NSKeyedArchiver.archivedData(withRootObject: cosigner, requiringSecureCoding: true)
            encodedCosigners.append(encoded)
        }
        let defaults = UserDefaults.standard
        defaults.set(encodedCosigners, forKey: "cosigners")
    }

    func mnemonic() -> String {
        return WalletManager.getMnemonic(us.fingerprint).description
    }

    func writeFile(folderUrl: URL, fileName: String, textData: Data) {
        guard folderUrl.startAccessingSecurityScopedResource() else {
            print("Access failure")
            return
        }
        defer { folderUrl.stopAccessingSecurityScopedResource() }

        let fileURL = NSURL.fileURL(withPath: fileName, relativeTo: folderUrl)

        do {
            try textData.write(to: fileURL)
        } catch {
            print("Failed to write")
        }

        #if targetEnvironment(simulator)
        print(folderUrl)
        #endif

    }
}
