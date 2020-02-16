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
    
    init() {
        (us, cosigners) = Signer.getSigners()
        threshold = UserDefaults.standard.integer(forKey:"threshold")
    }
    
    var hasWallet: Bool {
        return threshold > 0 && cosigners.count > 0
    }
    
    var hasCosigners: Bool {
        return cosigners.count > 0
    }
    
    mutating func wipeCosigners() {
        UserDefaults.standard.removeObject(forKey: "cosigners")
        self.cosigners = []
        self.threshold = 0
    }
    
    mutating func loadCosignerFile(_ url: URL) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: url.path), options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
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
        let composer = WalletComposer(us: self.us, signers: signers)
        let fileName = "wallet-" + signers.map { signer in
            return signer.fingerprint.hexString
        }.joined(separator: "-") + ".json";
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try! encoder.encode(composer)
        writeFile(folderUrl: url, fileName: fileName, textData: encoded)
    }
    
    func saveCosigners() {
        var encodedCosigners: [Data] = []
        for cosigner in self.cosigners {
            let encoded = try! NSKeyedArchiver.archivedData(withRootObject: cosigner, requiringSecureCoding: true)
            encodedCosigners.append(encoded)
        }
        let defaults = UserDefaults.standard
        defaults.set(encodedCosigners, forKey: "cosigners")
    }
    
    mutating func createWallet() {
        threshold = 2
        let defaults = UserDefaults.standard
        defaults.set(threshold, forKey: "threshold")
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
