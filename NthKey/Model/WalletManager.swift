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
    
    init() {
        (us, cosigners) = Signer.getSigners()
    }
    
    mutating func wipeCosigners() {
        UserDefaults.standard.removeObject(forKey: "cosigners")
        self.cosigners = []
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
                let vpub = Data(base58: p2wsh)!
                let vpubMarker = Data("02575483")! // Vpub (testnet, p2wsh, public)
                if (vpub.subdata(in: 0..<4) != vpubMarker) {
                    NSLog("Expected Vpub marker 0x%@, got 0x%@", vpubMarker.hexString, vpub.subdata(in: 0..<4).hexString)
                    return
                }
                let p2wsh_tpub = Data("043587cf")! + vpub.subdata(in: 4..<vpub.count)
                let cosigner = Signer(fingerprint: Data(xfp)!, derivation: BIP32Path(p2wsh_deriv)!, hdKey: HDKey(p2wsh_tpub.base58)!)
                let encoded = try! NSKeyedArchiver.archivedData(withRootObject: cosigner, requiringSecureCoding: true)
                let defaults = UserDefaults.standard
                defaults.set([encoded], forKey: "cosigners")
                defaults.set(2, forKey: "threshold")
                self.cosigners.append(cosigner)
            }
        } catch {
            NSLog("Something went wrong parsing JSON file")
            return
        }
    }
}
