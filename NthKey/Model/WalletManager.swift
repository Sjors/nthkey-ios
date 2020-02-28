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
    
    mutating func wipeCosigners() {
        assert(!self.hasWallet)
        UserDefaults.standard.removeObject(forKey: "cosigners")
        self.cosigners = []
    }
    
    mutating func wipeWallet() {
        UserDefaults.standard.removeObject(forKey: "hasWallet")
        self.hasWallet = false
    }
    
    mutating func loadCosignerFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
            // Check if it uses ColdCard format:
            if let jsonResult = jsonResult as? Dictionary<String, String>,
                let xfp = jsonResult["xfp"],
                let p2wsh_deriv = jsonResult["p2wsh_deriv"],
                let p2wsh = jsonResult["p2wsh"]
            {
                let extendedKey = Data(base58: p2wsh)!
                let expectedMarkers: Set<Data> = [
                    Data("043587cf")!, // tpub (testnet)
                    Data("02575483")! // Vpub (testnet, p2wsh, public)
                ]
                let marker = Data(extendedKey.subdata(in: 0..<4))
                if !expectedMarkers.contains(marker) {
                    NSLog("Expected tpub or Vpub marker (0x043587cf or 0x02575483), got 0x%@", marker.hexString)
                    return
                }
                // Convert marker to tpub for internal use:
                let p2wsh_tpub = Data("043587cf")! + extendedKey.subdata(in: 4..<extendedKey.count)
                let cosigner = Signer(fingerprint: Data(xfp)!, derivation: BIP32Path(p2wsh_deriv)!, hdKey: HDKey(p2wsh_tpub.base58)!, name: "")
                self.cosigners.append(cosigner)
                self.saveCosigners()
            } else if let composer = try? JSONDecoder().decode(WalletComposer.self, from: data) {
                outer: for item in composer.announcements {
                    let fingerprint = Data(item.key)! // WalletComposer already sanity checked this
                    let announcement = item.value
                    if fingerprint == us.fingerprint { continue }
                    for cosigner in cosigners {
                        if cosigner.fingerprint == fingerprint { continue outer }
                    }
                    guard let keys = announcement.keys else { continue }
                    guard let wsh_keys = keys["wsh"] else { continue }
                    guard let wsh_key_receive = wsh_keys["receive"] else { continue }
                    guard let wsh_key_change = wsh_keys["change"] else { continue }
                    
                    guard let (receive_derivation, receive_xpub) = try? WalletComposer.parseKey(wsh_key_receive, expectedFingerprint: fingerprint) else { continue }
                    guard let (change_derivation, change_xpub) = try? WalletComposer.parseKey(wsh_key_change, expectedFingerprint: fingerprint) else { continue }
                    guard receive_derivation == change_derivation && receive_xpub == change_xpub else { continue }
                    
                    if let sub_policy = announcement.sub_policy { // Assume pk(fingerprint) is not set
                        guard let subPolicy = try? WalletComposer.parseSubPolicy(sub_policy, expectedFingerprint: fingerprint) else { continue }
                        guard subPolicy == .pk else { continue }
                    }
                    
                    let derivation = BIP32Path(receive_derivation)!
                    guard let hdKey = HDKey(receive_xpub) else { return }
                    
                    let cosigner = Signer(fingerprint: fingerprint, derivation: derivation, hdKey: hdKey, name: announcement.name)
                    self.cosigners.append(cosigner)
                    self.saveCosigners()
                }
            } else {
                print("JSON format not recognized")
            }
        } catch {
            NSLog("Something went wrong parsing JSON file")
            return
        }
    }
    
    mutating func saveWalletComposer(_ url: URL) {
        var signers: [Signer] = [self.us]
        if self.hasWallet {
            signers.append(contentsOf: self.cosigners)
        }
        let composer = WalletComposer(us: self.us, signers: signers, threshold: self.hasWallet ? self.threshold : nil)
        let fileName = "wallet-" + signers.map { signer in
            return signer.fingerprint.hexString
        }.joined(separator: "-") + ".json";
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
        let encoded = try! encoder.encode(composer)
        writeFile(folderUrl: url, fileName: fileName, textData: encoded)
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
    
    mutating func createWallet(threshold: Int) {
        let defaults = UserDefaults.standard
        defaults.set(threshold, forKey: "threshold")
        defaults.set(true, forKey: "hasWallet")
        self.hasWallet = true
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
